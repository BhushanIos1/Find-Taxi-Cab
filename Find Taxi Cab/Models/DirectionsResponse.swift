//
//  DirectionsResponse.swift
//  Find Taxi Cab
//
//  Created by Claude on 12/09/26.
//

/// Google Directions API. Only the handful of fields the tracking map needs —
/// the encoded overview polyline, plus the leg's human-readable distance and
/// duration, which is where the "4.2 km" and "10 min" on screen come from.
struct DirectionsResponse: Decodable {

    let routes: [Route]

    struct Route: Decodable {
        let overviewPolyline: Polyline
        let legs: [Leg]

        enum CodingKeys: String, CodingKey {
            case overviewPolyline = "overview_polyline"
            case legs
        }
    }

    struct Polyline: Decodable {
        let points: String
    }

    struct Leg: Decodable {
        let distance: TextValue
        let duration: TextValue
    }

    struct TextValue: Decodable {
        let text: String
    }
}
