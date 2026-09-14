//
//  TrackingModel.swift
//  Find Taxi Cab
//
//  Created by Claude on 27/08/26.
//

import Foundation
import CoreLocation

/// Response shape for `get_bookdatatoclient` — matches Android's `MainActivity.getBookingData()`,
/// which reads exactly these five fields off the `data` object before launching `TrackingActivity`.
struct BookingDataToClientResponse: Decodable {

    let result: String?
    let message: String?
    let data: TrackingDriverInfo?

    enum CodingKeys: String, CodingKey {
        case result, message, error, data
    }

    init(from decoder: Decoder) throws {

        let c = try decoder.container(keyedBy: CodingKeys.self)

        result = try c.decodeIfPresent(String.self, forKey: .result)

        message = try c.decodeIfPresent(String.self, forKey: .message)
            ?? c.decodeIfPresent(String.self, forKey: .error)

        data = try c.decodeIfPresent(TrackingDriverInfo.self, forKey: .data)
    }
}

struct TrackingDriverInfo: Decodable, Equatable {

    let driverId: String?
    let driverName: String?
    let vehicleNo: String?
    let driverLat: String?
    let driverLng: String?
    let driverMobile: String?

    enum CodingKeys: String, CodingKey {
        case driverId = "driver_id"
        case driverName = "drivername"
        case vehicleNo = "vehicle_no"
        case driverLat = "driver_lat"
        case driverLng = "driver_lng"
        case driverMobile = "contact_no"
    }

    /// `driver_id` arrives as a bare number and the lat/lng as bare doubles. A
    /// plain `String?` decode throws on those, and one throw loses the whole
    /// object — which is why the driver's name could come back empty even on a
    /// perfectly good response.
    init(from decoder: Decoder) throws {

        let c = try decoder.container(keyedBy: CodingKeys.self)

        func text(_ key: CodingKeys) -> String? {
            if let value = try? c.decodeIfPresent(String.self, forKey: key) { return value }
            if let value = try? c.decodeIfPresent(Int.self, forKey: key) { return String(value) }
            if let value = try? c.decodeIfPresent(Double.self, forKey: key) { return String(value) }
            return nil
        }

        driverId = text(.driverId)
        driverName = text(.driverName)
        vehicleNo = text(.vehicleNo)
        driverLat = text(.driverLat)
        driverLng = text(.driverLng)
        driverMobile = text(.driverMobile)
    }

    init(
        driverId: String?,
        driverName: String?,
        vehicleNo: String?,
        driverLat: String?,
        driverLng: String?,
        driverMobile: String?
    ) {
        self.driverId = driverId
        self.driverName = driverName
        self.vehicleNo = vehicleNo
        self.driverLat = driverLat
        self.driverLng = driverLng
        self.driverMobile = driverMobile
    }
}

/// `POST /client_last_book` with `{cust_id}` — the rider's most recent booking,
/// used to drop them back into a trip that was still running when the app closed.
/// Android reads exactly these fields off `last_book` in `BookingPage.getBookingData()`.
struct ClientActiveBookingResponse: Decodable {

    let result: String?
    let message: String?
    let lastBook: ClientActiveBooking?

    enum CodingKeys: String, CodingKey {
        case result
        case message
        case lastBook = "last_book"
    }
}

struct ClientActiveBooking: Decodable, Equatable {

    let bookingId: String?
    let assignStatus: String?
    let driverId: String?
    let driverName: String?
    let vehicleNo: String?
    let driverMobile: String?
    let sourceAddress: String?
    let destinationAddress: String?
    let addedOn: String?

    enum CodingKeys: String, CodingKey {
        case bookingId = "booking_id"
        case assignStatus = "assign_status"
        case driverId = "driver_id"
        case driverName = "drivername"
        case vehicleNo = "vehicle_no"
        case driverMobile = "contact_no"
        case sourceAddress = "source_addr"
        case destinationAddress = "destination_addr"
        case addedOn = "added_on"
    }

    /// `booking_id` and `driver_id` routinely arrive as bare JSON numbers; a plain
    /// `String?` decode throws on those and loses the whole booking.
    init(from decoder: Decoder) throws {

        let c = try decoder.container(keyedBy: CodingKeys.self)

        func text(_ key: CodingKeys) -> String? {
            if let value = try? c.decodeIfPresent(String.self, forKey: key) { return value }
            if let value = try? c.decodeIfPresent(Int.self, forKey: key) { return String(value) }
            if let value = try? c.decodeIfPresent(Double.self, forKey: key) { return String(value) }
            return nil
        }

        bookingId = text(.bookingId)
        assignStatus = text(.assignStatus)
        driverId = text(.driverId)
        driverName = text(.driverName)
        vehicleNo = text(.vehicleNo)
        driverMobile = text(.driverMobile)
        sourceAddress = text(.sourceAddress)
        destinationAddress = text(.destinationAddress)
        addedOn = text(.addedOn)
    }
}

extension ClientActiveBooking {

    /// Android gates resume on exactly these three states in
    /// `BookingPage.continue_booking()` — a completed or cancelled trip must not
    /// pull the rider back into tracking.
    var isResumable: Bool {
        ["accept", "pickcustomer", "onboard"].contains(assignStatus?.lowercased() ?? "")
    }
}

/// Response shape for `get_driverlatlng` — the 5s tracking poll.
struct DriverLatLngResponse: Decodable {

    let result: String?
    let driverData: DriverLatLng?

    enum CodingKeys: String, CodingKey {
        case result
        case driverData = "driver_data"
    }

    init(from decoder: Decoder) throws {

        let c = try decoder.container(keyedBy: CodingKeys.self)

        result = try? c.decodeIfPresent(String.self, forKey: .result)
        driverData = try? c.decodeIfPresent(DriverLatLng.self, forKey: .driverData)
    }
}

struct DriverLatLng: Decodable {

    let driverLat: String?
    let driverLng: String?

    enum CodingKeys: String, CodingKey {
        case driverLat = "driver_lat"
        case driverLng = "driver_lng"
    }

    /// Coordinates are sent as bare JSON numbers — `22.5726`, not `"22.5726"` —
    /// and a plain `String?` decode throws on those. The throw propagated up
    /// through `DriverLatLngResponse`, was swallowed by the poll's catch block,
    /// and the driver simply never appeared on the customer's map.
    init(from decoder: Decoder) throws {

        let c = try decoder.container(keyedBy: CodingKeys.self)

        func text(_ key: CodingKeys) -> String? {
            if let value = try? c.decodeIfPresent(String.self, forKey: key) { return value }
            if let value = try? c.decodeIfPresent(Double.self, forKey: key) { return String(value) }
            if let value = try? c.decodeIfPresent(Int.self, forKey: key) { return String(value) }
            return nil
        }

        driverLat = text(.driverLat)
        driverLng = text(.driverLng)
    }
}

extension DriverLatLng {

    var coordinate: CLLocationCoordinate2D? {

        guard let latText = driverLat, let lat = Double(latText),
              let lngText = driverLng, let lng = Double(lngText),
              lat != 0 || lng != 0 else {
            return nil
        }

        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}

/// Response shape for `get_fair` — matches Android's `TrackingActivity.getFairDetails()`.
struct FareDetailsResponse: Decodable {

    let result: String
    let message: String?
    let fairData: FareBreakdown?

    enum CodingKeys: String, CodingKey {
        case result
        case message
        case fairData = "fair_data"
    }
}

struct FareBreakdown: Decodable, Equatable {

    let baseFare: String?
    let percentAmt: String?
    let totalAmt: String?
    let driverTip: String?

    enum CodingKeys: String, CodingKey {
        case baseFare = "base_fair"
        case percentAmt = "percent_amt"
        case totalAmt = "total_amt"
        case driverTip = "driver_tip"
    }
}
