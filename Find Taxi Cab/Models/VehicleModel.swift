//
//  VehicleModel.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 27/06/26.
//

import Foundation

struct VehicleListResponse: Decodable {
    
    let result: String
    let message: String?
    let data: [VehicleModel]?
    
    enum CodingKeys: String, CodingKey {
        case result
        case message
        case data
    }
}

struct VehicleModel: Codable, Identifiable {
    
    let id = UUID()
    
    let price: String
    let seater: Int
    let distance: Double
    
    enum CodingKeys: String, CodingKey {
        case price
        case seater
        case distance
    }
}

/// `POST /add_booking`.
///
/// Only `result` is guaranteed. On success the server sends `message` and
/// `booking_id`; on failure it sends neither — it sends `error` instead
/// ("No Driver Present"). Requiring the success-shape fields made every failure
/// throw a decoding error, which hid the real reason behind "decodingError".
struct CreateBookingResponse: Decodable {

    let result: String
    let message: String?
    let bookingId: Int?

    enum CodingKeys: String, CodingKey {
        case result, message, error
        case bookingId = "booking_id"
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        result = try container.decode(String.self, forKey: .result)

        message = try container.decodeIfPresent(String.self, forKey: .message)
            ?? container.decodeIfPresent(String.self, forKey: .error)

        // Quoted or bare — the backend has sent it both ways.
        if let value = try? container.decodeIfPresent(Int.self, forKey: .bookingId) {
            bookingId = value
        } else if let text = try? container.decodeIfPresent(String.self, forKey: .bookingId) {
            bookingId = Int(text)
        } else {
            bookingId = nil
        }
    }
}
