//
//  TripContext.swift
//  Find Taxi Cab
//
//  Created by Claude on 12/09/26.
//

import CoreLocation

/// `CLLocationCoordinate2D` is not `Hashable`, and `AppRoute` has to be — so the
/// route carries this instead.
struct Coordinate: Hashable {

    let latitude: Double
    let longitude: Double

    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// `(0, 0)` is Null Island, not a place anyone is booked from — treat it as
    /// "no coordinate" so a missing value can't drag the map into the Atlantic.
    init?(latitude: Double?, longitude: Double?) {

        guard let latitude, let longitude,
              latitude != 0 || longitude != 0 else {
            return nil
        }

        self.latitude = latitude
        self.longitude = longitude
    }
}

/// Everything the tracking screen needs, gathered in one value rather than a
/// ten-parameter route case.
///
/// The driver fields come from `get_bookdatatoclient` / `client_last_book`; the
/// trip fields are what the rider chose when booking. `fareText` and
/// `distanceText` come from the `vehicle_list` row they tapped — the server has
/// already priced the trip by then, so there is nothing further to ask it for.
///
/// Coordinates are optional on purpose: resuming a trip from `client_last_book`
/// gives addresses but no lat/lng, and the screen has to stay useful without
/// them (driver still tracked, just no drawn route).
struct TripContext: Hashable {

    let bookingId: String
    let driverId: String
    let driverName: String
    let vehicleNo: String
    let driverMobile: String

    var pickupAddress: String = ""
    var destinationAddress: String = ""

    var pickupCoordinate: Coordinate?
    var destinationCoordinate: Coordinate?

    var fareText: String = ""
    var distanceText: String = ""

    /// The booking's `assign_status` when it is known — `client_last_book` and
    /// `get_bookdatatoclient` both return it.
    ///
    /// Needed because a resumed trip missed the pushes that fired while the app
    /// was closed: without it, reopening mid-journey would route the map back to
    /// the pickup point and offer a Cancel button for a trip the customer is
    /// already sitting in.
    var assignStatus: String = ""

    var isOnboard: Bool {
        assignStatus.lowercased() == "onboard"
    }
}
