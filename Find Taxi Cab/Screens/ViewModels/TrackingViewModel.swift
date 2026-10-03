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

    /// Set whenever `ride_otp` appears on the booking and differs from the
    /// last code shown. The driver app can issue a new code (the OTP sheet's
    /// own "Resend OTP") if the first one was lost or the customer missed it
    /// — tracking the *value* rather than a one-shot flag means this popup
    /// reopens with the new code instead of staying silent after the first.
    @Published var otpToShow: String?
    private var lastShownOTP: String?

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

    /// The route is drawn as three stacked strokes, the way Uber and Google Maps
    /// both do it — the same pattern as the driver app's `NavigationViewModel`.
    ///   • `traveledPolyline` — muted, the part already driven
    ///   • `routeCasingPolyline` — dark, widest, the outline that lifts the route
    ///     off the map and keeps it legible over roads, parks and satellite tiles
    ///   • `routeCorePolyline` — the bright core, drawn on top
    private var traveledPolyline: GMSPolyline?
    private var routeCasingPolyline: GMSPolyline?
    private var routeCorePolyline: GMSPolyline?

    /// Small dots layered the same way as the line itself, sat over each
    /// endpoint — `GMSPolyline` has no line-cap property, so every line it
    /// draws is flat-cut, and without these the route reads as a rectangle
    /// with pins stuck in it rather than one continuous rounded shape.
    private var startCapMarker: GMSMarker?
    private var endCapMarker: GMSMarker?

    /// Kept so the driver marker can be snapped onto the route, and progress
    /// recomputed against it, on every poll tick — the drawn polylines get
    /// trimmed each time, so they can't be their own source.
    private var fullRoutePath: GMSPath?

    /// The driver marker's last placed (post-snap) position — used to derive
    /// a heading from consecutive polls when there's no route yet to read a
    /// segment bearing from.
    private var lastDriverCoordinate: CLLocationCoordinate2D?

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

            if let otp = info.rideOtp, !otp.isEmpty, otp != lastShownOTP {

                print("🔑 TRIP OTP RECEIVED for booking \(bookingId) — \(lastShownOTP == nil ? "first code" : "new code, driver resent")")

                lastShownOTP = otp
                otpToShow = otp
            }

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

    /// `bookingId` is only needed here to keep checking for the OTP appearing
    /// or changing — that stops once the trip moves past `.toPickup`, since
    /// `ride_otp` only matters before the customer is actually in the car; a
    /// driver's resend after boarding would just be a stale, irrelevant code.
    func startPolling(driverId: String, bookingId: String) {

        stopPolling()

        let timer = Timer.scheduledTimer(
            withTimeInterval: Self.pollInterval,
            repeats: true
        ) { [weak self] _ in

            Task { @MainActor [weak self] in

                await self?.fetchDriverLocation(driverId: driverId)

                guard let self, self.phase == .toPickup else { return }
                await self.loadDriverDetails(bookingId: bookingId)
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

        traveledPolyline?.map = nil
        traveledPolyline = nil

        routeCasingPolyline?.map = nil
        routeCasingPolyline = nil

        routeCorePolyline?.map = nil
        routeCorePolyline = nil

        startCapMarker?.map = nil
        startCapMarker = nil

        endCapMarker?.map = nil
        endCapMarker = nil

        fullRoutePath = nil
        lastDriverCoordinate = nil

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

    /// `coordinate` is the raw polled fix. Uber-style map matching snaps it onto
    /// the nearest point *on* the drawn route rather than placing the marker at
    /// the raw value — a polled position that's a few meters off the road used
    /// to show up as the taxi sitting just off the line it was supposedly
    /// following. Falls back to the raw fix when there's no route yet, or the
    /// driver is genuinely off it, rather than dragging them back onto a route
    /// they're not on.
    func moveDriverMarker(to rawCoordinate: CLLocationCoordinate2D) {

        guard let mapView else { return }

        let snapped = fullRoutePath.flatMap { projectOntoRoute(rawCoordinate, path: $0) }
        let coordinate = snapped?.coordinate ?? rawCoordinate

        let bearing = snapped?.bearing
            ?? headingSincePreviousFix(to: coordinate)
            ?? driverMarker?.rotation
            ?? 0

        if let driverMarker {

            // Slides between the two polled positions instead of teleporting.
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.0)
            driverMarker.position = coordinate
            driverMarker.rotation = bearing
            CATransaction.commit()

        } else {

            let marker = GMSMarker(position: coordinate)
            marker.title = "Your Driver"
            marker.icon = MapMarkerIcon.driver
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.rotation = bearing
            marker.isFlat = true // rotates with the map instead of standing upright
            marker.map = mapView

            driverMarker = marker

            // Only frame on the very first fix; later ticks leave the camera be.
            if routeTarget == nil {
                mapView.animate(to: GMSCameraPosition.camera(withTarget: coordinate, zoom: 16))
            }
        }

        lastDriverCoordinate = coordinate

        updateRemainingRoute(from: coordinate, atSegment: snapped?.segmentIndex)
    }

    /// Heading between the last two polled fixes — the fallback for before any
    /// route exists to read a segment bearing from. Polls land every 5s, far
    /// enough apart that even city-block movement gives a usable direction.
    private func headingSincePreviousFix(to coordinate: CLLocationCoordinate2D) -> CLLocationDirection? {

        guard let previous = lastDriverCoordinate,
              GMSGeometryDistance(previous, coordinate) > 1 else {
            return nil
        }

        return GMSGeometryHeading(previous, coordinate)
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

            drawRoute(route.path)

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

    func drawRoute(_ path: GMSPath) {

        guard let mapView else { return }

        traveledPolyline?.map = nil
        routeCasingPolyline?.map = nil
        routeCorePolyline?.map = nil

        fullRoutePath = path

        // Bottom layer: the driven-so-far line. Starts empty and fills in as the
        // trip progresses, so the route visibly "burns down" behind the car.
        let traveled = GMSPolyline()
        traveled.strokeWidth = RouteStyle.traveledWidth
        traveled.strokeColor = RouteStyle.traveledColor
        traveled.geodesic = true
        traveled.zIndex = RouteStyle.traveledZ
        traveled.map = mapView
        traveledPolyline = traveled

        let casing = GMSPolyline(path: path)
        casing.strokeWidth = RouteStyle.casingWidth
        casing.strokeColor = RouteStyle.casingColor
        casing.geodesic = true
        casing.zIndex = RouteStyle.casingZ
        casing.map = mapView
        routeCasingPolyline = casing

        let core = GMSPolyline(path: path)
        core.strokeWidth = RouteStyle.coreWidth
        core.strokeColor = RouteStyle.coreColor
        core.geodesic = true
        core.zIndex = RouteStyle.coreZ
        core.map = mapView
        routeCorePolyline = core

        if path.count() > 0 {

            // Directions snaps the requested pickup/drop-off onto the nearest
            // road before routing to it — a building is rarely sitting exactly
            // on one. Re-anchoring the pin to the route's own endpoint (rather
            // than leaving it at the raw booking coordinate `refreshEndpointMarkers`
            // placed it at) guarantees the line runs right into it.
            let endCoordinate = path.coordinate(at: path.count() - 1)
            pickupMarker?.position = endCoordinate

            startCapMarker?.map = nil
            endCapMarker?.map = nil
            startCapMarker = makeCapMarker(at: path.coordinate(at: 0))
            endCapMarker = makeCapMarker(at: endCoordinate)
        }

        guard !hasFramedRoute else { return }
        hasFramedRoute = true

        var bounds = GMSCoordinateBounds(path: path)
        if let driverCoord = driverMarker?.position {
            bounds = bounds.includingCoordinate(driverCoord)
        }
        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 60))
    }

    private func makeCapMarker(at coordinate: CLLocationCoordinate2D) -> GMSMarker {
        let marker = GMSMarker(position: coordinate)
        marker.icon = RouteStyle.capIcon
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.zIndex = RouteStyle.capZ
        marker.isFlat = true
        marker.tracksViewChanges = false // a static dot — no need to redraw it every frame
        marker.map = mapView
        return marker
    }

    /// Finds the closest point to `coordinate` lying *on* the route itself —
    /// not just the closest existing vertex — along with the heading of the
    /// segment it landed on and that segment's start index. Mirrors the driver
    /// app's `NavigationViewModel.projectOntoRoute`.
    private func projectOntoRoute(
        _ coordinate: CLLocationCoordinate2D,
        path: GMSPath
    ) -> (coordinate: CLLocationCoordinate2D, bearing: CLLocationDirection, segmentIndex: UInt)? {

        guard path.count() > 1 else { return nil }

        var best: (point: CLLocationCoordinate2D, index: UInt, distance: CLLocationDistance)?

        for i in 0..<(path.count() - 1) {
            let a = path.coordinate(at: i)
            let b = path.coordinate(at: i + 1)

            let projected = closestPoint(on: a, b, to: coordinate)
            let distance = GMSGeometryDistance(coordinate, projected)

            if best == nil || distance < best!.distance {
                best = (projected, i, distance)
            }
        }

        guard let best else { return nil }

        // Polled positions can land well off the road (sparse updates, a
        // slightly-off address). Beyond this it's no longer "noise to smooth
        // over" — show the real position rather than pinning it to a route
        // the driver may not actually be on.
        guard best.distance < 40 else { return nil }

        let a = path.coordinate(at: best.index)
        let b = path.coordinate(at: best.index + 1)

        return (best.point, GMSGeometryHeading(a, b), best.index)
    }

    /// Closest point on segment `a`→`b` to point `p`, via a flat-plane
    /// projection (longitude scaled by `cos(latitude)` to correct for its
    /// shrinking real-world distance away from the equator).
    private func closestPoint(
        on a: CLLocationCoordinate2D,
        _ b: CLLocationCoordinate2D,
        to p: CLLocationCoordinate2D
    ) -> CLLocationCoordinate2D {

        let cosLat = cos(p.latitude * .pi / 180)

        let ax = a.longitude * cosLat, ay = a.latitude
        let bx = b.longitude * cosLat, by = b.latitude
        let px = p.longitude * cosLat, py = p.latitude

        let dx = bx - ax, dy = by - ay
        let lengthSquared = dx * dx + dy * dy

        guard lengthSquared > 0 else { return a }

        let t = max(0, min(1, ((px - ax) * dx + (py - ay) * dy) / lengthSquared))

        return CLLocationCoordinate2D(latitude: ay + t * dy, longitude: (ax + t * dx) / cosLat)
    }

    /// Splits the route at the driver's current point: everything behind them
    /// becomes the muted "traveled" line, everything ahead stays bright.
    /// Measured against `fullRoutePath` rather than the drawn polylines, since
    /// those get trimmed each tick and would otherwise drift.
    ///
    /// The split is seamed at `coord` itself — not the nearest vertex — so the
    /// traveled/remaining boundary always sits exactly under the marker rather
    /// than snapping forward or back by up to one polyline segment.
    private func updateRemainingRoute(from coord: CLLocationCoordinate2D, atSegment segmentIndex: UInt?) {

        guard let path = fullRoutePath, path.count() > 1 else { return }

        let index = segmentIndex ?? nearestVertexIndex(to: coord, on: path)

        let traveled = GMSMutablePath()
        for i in 0...index {
            traveled.add(path.coordinate(at: i))
        }
        traveled.add(coord)

        let remaining = GMSMutablePath()
        remaining.add(coord)
        for i in (index + 1)..<path.count() {
            remaining.add(path.coordinate(at: i))
        }

        traveledPolyline?.path = traveled

        // Casing and core share the same remaining path so the border stays
        // registered to the bright stroke on every frame.
        routeCasingPolyline?.path = remaining
        routeCorePolyline?.path = remaining
    }

    /// Fallback for `updateRemainingRoute` when `projectOntoRoute` found no
    /// usable segment (driver off-route) — nearest existing vertex.
    private func nearestVertexIndex(to coord: CLLocationCoordinate2D, on path: GMSPath) -> UInt {

        var nearestIndex: UInt = 0
        var minDist = CLLocationDistance.greatestFiniteMagnitude

        for i in 0..<path.count() {
            let dist = GMSGeometryDistance(coord, path.coordinate(at: i))
            if dist < minDist {
                minDist = dist
                nearestIndex = i
            }
        }

        return nearestIndex
    }
}

/// Uber-style route styling, matching the driver app's `RouteStyle`. The
/// widths matter as much as the colours: a thin line looks like a map
/// annotation, a thick cased line reads as "this is your route".
private enum RouteStyle {

    static let casingWidth: CGFloat = 18
    static let coreWidth: CGFloat = 12
    static let traveledWidth: CGFloat = 12

    /// Near-black with a blue cast — dark enough to separate the route from any
    /// tile underneath without looking like a plain black scribble.
    static let casingColor = UIColor(red: 0.05, green: 0.09, blue: 0.17, alpha: 0.95)

    /// The app's own blue, so the live route reads as this app's rather than a
    /// generic maps-SDK default.
    static let coreColor = UIColor(AppColors.appBlueColor)

    /// Already-driven portion: still visible for context, clearly de-emphasised.
    static let traveledColor = UIColor(white: 0.58, alpha: 0.50)

    static let traveledZ: Int32 = 1
    static let casingZ: Int32 = 2
    static let coreZ: Int32 = 3
    static let capZ: Int32 = 4

    /// `GMSPolyline` has no line-cap property — every line is drawn flat-cut.
    /// A small dot layered the same way as the line (dark casing ring, bright
    /// core center) sits over each endpoint and rounds it off.
    static let capDiameter: CGFloat = casingWidth

    static let capIcon: UIImage = {
        let size = CGSize(width: capDiameter, height: capDiameter)
        return UIGraphicsImageRenderer(size: size).image { _ in
            casingColor.setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()

            let coreInset = (capDiameter - coreWidth) / 2
            coreColor.setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size).insetBy(dx: coreInset, dy: coreInset)).fill()
        }
    }()
}

// MARK: - Booking actions

extension TrackingViewModel {

    /// Rider-initiated cancel — `api/cancel_book_client`. Android's own
    /// `TrackingActivity.cancelBooking()` sends no reason at all; requiring one
    /// is a new requirement on top of that call, not a port of Android's.
    func cancelBooking(bookingId: String, reason: String) {

        guard !isCancelling else { return }

        isCancelling = true

        Task {

            defer { isCancelling = false }

            do {

                let response: CommonResponse = try await APIClient.shared.request(
                    CustomerAPI.cancelBooking(bookingId: bookingId, reason: reason),
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
