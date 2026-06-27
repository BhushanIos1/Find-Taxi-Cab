//
//  AppRoute.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 26/02/26.
//

import SwiftUI

enum AppRoute: Hashable {
    
    // Auth Flow
    case registration
    case login
    case forgotPassword
    case landingPage
    
    case home
    case bookingPreview(
        pickupAddress: String,
        destinationAddress: String,
        fromLat: Double,
        fromLong: Double,
        toLat: Double,
        toLong: Double
    )
    case getCabScreen(pickupAddress: String,
                      destinationAddress: String,
                      fromLat: Double,
                      fromLong: Double,
                      toLat: Double,
                      toLong: Double,
                      specialDisability: String,
                      passengerCount: Int)
    
    case history
    case booking
    case emergency
    case setting
    case changePassword
    case editCardDetails
    case promotion
    case about
    case help
}
