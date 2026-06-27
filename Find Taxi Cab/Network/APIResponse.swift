//
//  APIResponse.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 21/03/26.
//

struct APIResponse<T: Decodable>: Decodable {
    
    let result: String?
    let message: String?
    let data: T?
    let success: Int?
    
    var isSuccess: Bool {
        if result == "success" { return true }
        if success == 1 || success == 200 { return true }
        return false
    }
}

struct CommonResponse: Codable {
    let result: String?
    let message: String?
}
