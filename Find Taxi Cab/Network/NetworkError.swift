//
//  NetworkError.swift
//  Find Taxi Cab Driver
//
//  Created by Bhushan Kumar on 21/03/26.
//

import Foundation

enum NetworkError: LocalizedError {
    
    case serverMessage(String)
    case decodingError
    case noInternet
    case timeout
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .serverMessage(let msg): return msg
        case .decodingError: return "Decoding failed"
        case .noInternet: return "No Internet Connection"
        case .timeout: return "Request Timeout"
        case .unknown: return "Something went wrong"
        }
    }
}
