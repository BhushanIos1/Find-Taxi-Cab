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
