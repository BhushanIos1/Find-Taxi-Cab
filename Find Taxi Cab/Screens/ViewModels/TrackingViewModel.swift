//
//  TrackingViewModel.swift
//  Find Taxi Cab
//
//  Created by Claude on 27/08/26.
//

import Foundation
import SwiftUI
import CoreLocation
import GoogleMaps

@MainActor
final class TrackingViewModel: NSObject, ObservableObject {

    @Published var fareDetails: FareBreakdown?
    @Published var isCancelling = false
    @Published var cancelState: BookingState?

    /// Live from the Directions API — "10 min" / "4.2 km" to whichever point the
    /// trip is currently heading for. Nil until the first route lands, so the UI
    /// can fall back to the booked figures rather than showing "0".
    @Published var etaText: String?
    @Published var routeDistanceText: String?

    /// Which leg the route describes. Before pickup the map answers "how long
    /// until my taxi arrives"; once the customer is aboard the same map has to
    /// answer "how long until I get there", which is a different destination and
    /// a different question.
    @Published private(set) var phase: TripPhase = .toPickup

    enum TripPhase {
        case toPickup
        case toDestination
    }

    /// Driver name / plate / phone as the server currently has them, fetched by
    /// this screen rather than inherited from whichever screen pushed it.
    /// Resuming a trip used to arrive here with whatever `client_last_book`
    /// happened to carry, so a gap in that response showed as a blank name.
    @Published var driverInfo: TrackingDriverInfo?

    /// The map is owned by `GoogleMapView`'s `UIViewRepresentable`. Holding it
    /// weakly means this view model can never be the reason it stays alive.
    weak var mapView: GMSMapView?

    private var driverMarker: GMSMarker?
    private var pickupMarker: GMSMarker?
    private var routePolyline: GMSPolyline?

    /// Where the driver was when we last asked for a route, and when.
    private var lastRoutedDriverLocation: CLLocationCoordinate2D?
    private var lastRouteRefresh: Date?

    /// Guards against a slow Directions call overlapping the next poll tick.
    private var isFetchingRoute = false

    private var pickupCoordinate: CLLocationCoordinate2D?
    private var destinationCoordinate: CLLocationCoordinate2D?

    /// Where the current leg is heading.
    private var routeTarget: CLLocationCoordinate2D? {
        phase == .toPickup ? pickupCoordinate : destinationCoordinate
    }

    /// Has the camera been framed once? After that the rider is free to pan
    /// without the next poll yanking the map back.
    private var hasFramedRoute = false

    /// 5000 ms — matches Android's `TrackingActivity` (`private int delay = 5000`)
    /// polling `api/get_driverlatlng` for as long as the trip is in progress.
    private static let pollInterval: TimeInterval = 5

    /// Directions calls are billed per request, and the driver only *posts* its
    /// position every 7s, so re-routing on every 5s poll would buy nothing. Ask
    /// again only once the driver has actually moved, or the route has gone stale.
    private static let routeRefreshDistance: CLLocationDistance = 100
    private static let routeRefreshInterval: TimeInterval = 30

    private var pollTimer: Timer?

    /// The timer retains its target until invalidated, so a screen that vanished
    /// without `stopPolling()` would otherwise keep firing forever.
    deinit {
        pollTimer?.invalidate()
    }
}

// MARK: - Driver details

extension TrackingViewModel {

    /// `POST /get_bookdatatoclient` with `{book_id}` — the one call that returns
    /// every driver field the screen shows, keyed only on the booking id. Android
    /// uses it in `MainActivity.getBookingData()` purely to populate the intent
    /// before opening tracking; here it also refreshes the details in place and
    /// seeds the map with the driver's last known position, so the car appears
    /// immediately instead of after the first poll.
    ///
    /// Returns the driver id it found, so the caller can start polling even when
    /// it was pushed here without one.
    @discardableResult
    func loadDriverDetails(bookingId: String) async -> String? {

        guard !bookingId.isEmpty else { return nil }

        do {

            let response: BookingDataToClientResponse = try await APIClient.shared.request(
                CustomerAPI.getBookingDataToClient(bookingId: bookingId),
                responseType: BookingDataToClientResponse.self
            )

            guard let info = response.data else {
                print("ℹ️ TRACKING: no driver data yet —", response.message ?? "")
                return nil
            }

            print("🚕 TRACKING DRIVER: \(info.driverName ?? "nil") / \(info.vehicleNo ?? "nil")")

            driverInfo = info

            if let latText = info.driverLat, let lat = Double(latText),
               let lngText = info.driverLng, let lng = Double(lngText),
               lat != 0 || lng != 0 {

                moveDriverMarker(to: CLLocationCoordinate2D(latitude: lat, longitude: lng))
            }

            return info.driverId

        } catch {

            print("❌ TRACKING DRIVER DETAILS ERROR:", error)
            return nil
        }
    }
}

// MARK: - Polling

extension TrackingViewModel {

    func startPolling(driverId: String) {

        stopPolling()

        let timer = Timer.scheduledTimer(
            withTimeInterval: Self.pollInterval,
            repeats: true
        ) { [weak self] _ in

            Task { @MainActor [weak self] in
                await self?.fetchDriverLocation(driverId: driverId)
            }
        }

        pollTimer = timer
        timer.fire()
    }

    func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    /// Drops every overlay this view model put on the shared map. Without it the
    /// markers and polyline outlive the screen, since `GoogleMapView` recycles
    /// its `GMSMapView`.
    func clearMapOverlays() {

        driverMarker?.map = nil
        driverMarker = nil

        pickupMarker?.map = nil
        pickupMarker = nil

        routePolyline?.map = nil
        routePolyline = nil

        hasFramedRoute = false
        lastRoutedDriverLocation = nil
        lastRouteRefresh = nil
        phase = .toPickup
    }
}

// MARK: - Map

extension TrackingViewModel {

    /// Called once the screen knows the trip's two endpoints.
    func setRoute(
        pickup: CLLocationCoordinate2D?,
        destination: CLLocationCoordinate2D?
    ) {

        pickupCoordinate = pickup
        destinationCoordinate = destination

        refreshEndpointMarkers()
    }

    /// `book_onboard` — the customer is in the car. The pickup point stops being
    /// relevant and the route re-draws to the drop-off, so the ETA and remaining
    /// distance now describe the journey rather than the wait.
    func beginTripToDestination() {

        guard phase != .toDestination else { return }

        phase = .toDestination

        // Force the next poll to re-route rather than wait out the throttle —
        // this is the one moment the customer is watching for the change.
        lastRoutedDriverLocation = nil
        lastRouteRefresh = nil
        hasFramedRoute = false

        etaText = nil
        routeDistanceText = nil

        refreshEndpointMarkers()
    }

    /// Shows only the marker the current leg is heading for. Leaving the pickup
    /// pin up mid-journey suggests the car is still going back for it.
    private func refreshEndpointMarkers() {

        guard let mapView else { return }

        pickupMarker?.map = nil
        pickupMarker = nil

        guard let target = routeTarget else { return }

        let marker = GMSMarker(position: target)
        marker.title = phase == .toPickup ? "Pickup" : "Drop-off"
        marker.icon = phase == .toPickup ? MapMarkerIcon.pickup : MapMarkerIcon.destination
        // A round badge sits *on* its coordinate; the default anchor would
        // hang it below by half its height.
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.map = mapView

        pickupMarker = marker
    }
}

extension TrackingViewModel {

    func moveDriverMarker(to coordinate: CLLocationCoordinate2D) {

        guard let mapView else { return }

        if let driverMarker {

            // Slides between the two polled positions instead of teleporting.
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.0)
            driverMarker.position = coordinate
            CATransaction.commit()

        } else {

            let marker = GMSMarker(position: coordinate)
            marker.title = "Your Driver"
            marker.icon = MapMarkerIcon.driver
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.map = mapView

            driverMarker = marker

            // Only frame on the very first fix; later ticks leave the camera be.
            if routeTarget == nil {
                mapView.animate(to: GMSCameraPosition.camera(withTarget: coordinate, zoom: 16))
            }
        }
    }
}

private extension TrackingViewModel {

    func fetchDriverLocation(driverId: String) async {

        do {

            let response: DriverLatLngResponse = try await APIClient.shared.request(
                CustomerAPI.getDriverLatLng(driverId: driverId),
                responseType: DriverLatLngResponse.self
            )

            guard let coordinate = response.driverData?.coordinate else {
                print("ℹ️ DRIVER LOCATION: no usable coordinate in response")
                return
            }

            moveDriverMarker(to: coordinate)
            await refreshRouteIfNeeded(from: coordinate)

        } catch {

            print("❌ DRIVER LOCATION POLL ERROR:", error)
        }
    }

    func refreshRouteIfNeeded(from driverLocation: CLLocationCoordinate2D) async {

        guard let target = routeTarget, !isFetchingRoute else { return }

        if !shouldRefreshRoute(for: driverLocation) { return }

        isFetchingRoute = true
        defer { isFetchingRoute = false }

        do {

            // Origin is the car's polled position. Before pickup that is the
            // taxi on its way; afterwards the customer is inside it, so it is
            // also the customer's own location — one source, always current,
            // and it doesn't depend on the customer's phone having a GPS fix.
            let route = try await DirectionsService.fetchRoute(
                origin: driverLocation,
                destination: target
            )

            lastRoutedDriverLocation = driverLocation
            lastRouteRefresh = Date()

            etaText = route.durationText
            routeDistanceText = route.distanceText

            draw(route.path)

        } catch {

            // A failed route leaves the last one on screen — better a slightly
            // stale line than a map that blinks empty every time the network dips.
            print("❌ ROUTE FETCH ERROR:", error)
        }
    }

    func shouldRefreshRoute(for driverLocation: CLLocationCoordinate2D) -> Bool {

        guard let lastRoutedDriverLocation, let lastRouteRefresh else {
            return true
        }

        let moved = CLLocation(
            latitude: lastRoutedDriverLocation.latitude,
            longitude: lastRoutedDriverLocation.longitude
        )
        .distance(
            from: CLLocation(
                latitude: driverLocation.latitude,
                longitude: driverLocation.longitude
            )
        )

        if moved >= Self.routeRefreshDistance { return true }

        return Date().timeIntervalSince(lastRouteRefresh) >= Self.routeRefreshInterval
    }

    func draw(_ path: GMSPath) {

        guard let mapView else { return }

        routePolyline?.map = nil

        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 6
        polyline.strokeColor = UIColor(AppColors.appBlueColor)
        polyline.geodesic = true
        polyline.map = mapView

        routePolyline = polyline

        guard !hasFramedRoute else { return }
        hasFramedRoute = true

        let bounds = GMSCoordinateBounds(path: path)
        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 60))
    }
}

// MARK: - Booking actions

extension TrackingViewModel {

    /// Rider-initiated cancel — `api/cancel_book_client`, same params Android's
    /// `TrackingActivity.cancelBooking()` sends.
    func cancelBooking(bookingId: String) {

        guard !isCancelling else { return }

        isCancelling = true

        Task {

            defer { isCancelling = false }

            do {

                let response: CommonResponse = try await APIClient.shared.request(
                    CustomerAPI.cancelBooking(bookingId: bookingId),
                    responseType: CommonResponse.self
                )

                if response.result?.lowercased() == "success" {
                    cancelState = .success(response.message ?? "Booking Cancelled")
                } else {
                    cancelState = .failure(response.message ?? "Could Not Cancel Booking")
                }

            } catch {

                cancelState = .failure(error.localizedDescription)
            }
        }
    }

    /// Triggered by the `book_complete` push — `api/get_fair`, same endpoint and
    /// param Android's `TrackingActivity.getFairDetails()` uses.
    func getFareDetails(bookingId: String) {

        Task {

            do {

                let response: FareDetailsResponse = try await APIClient.shared.request(
                    CustomerAPI.getFareDetails(bookingId: bookingId),
                    responseType: FareDetailsResponse.self
                )

                if response.result.lowercased() == "success" {
                    fareDetails = response.fairData
                }

            } catch {

                print("❌ FARE DETAILS ERROR:", error)
            }
        }
    }

    func submitFeedback(bookingId: String, rating: Int, comment: String) {

        Task {

            do {

                let response: CommonResponse = try await APIClient.shared.request(
                    CustomerAPI.customerFeedback(
                        bookingId: bookingId,
                        feedback: comment,
                        rate: "\(rating)"
                    ),
                    responseType: CommonResponse.self
                )

                print("✅ FEEDBACK SUBMITTED:", response.result ?? "")

            } catch {

                print("❌ FEEDBACK SUBMIT ERROR:", error)
            }
        }
    }
}
