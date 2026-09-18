//
//  RouteBuilder.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 28/02/26.
//

import SwiftUI

struct RouteBuilder {
    
    @ViewBuilder
    static func build(_ route: AppRoute) -> some View {
        
        switch route {
            
        case .home:
            HomeScreen()
            
        case .bookingPreview(let pickupAddress, let destinationAddress, let fromLat, let fromLong, let toLat, let toLong):
            BookingPreview(
                pickupAddress: pickupAddress,
                destinationAddress: destinationAddress,
                fromLat: fromLat,
                fromLong: fromLong,
                toLat: toLat,
                toLong: toLong
            )
            
        case .getCabScreen(let pickupAddress, let destinationAddress, let fromLat, let fromLong, let toLat, let toLong, let specialDisability, let passengerCount):
            GetCabScreen(pickupAddress: pickupAddress, destinationAddress: destinationAddress, fromLat: fromLat, fromLong: fromLong, toLat: toLat, toLong: toLong, disability: specialDisability, numberOfPassenger: passengerCount)

        case .tracking(let trip):
            TrackingScreen(trip: trip)

        case .chat(let bookingId):
            ChatView(bookingId: bookingId)

        case .history:
            HistoryScreen()
            
        case .booking:
            BookingScreen()
            
        case .emergency:
            EmergencyScreen()
            
        case .setting:
            SettingScreen()
            
        case .changePassword:
            ChangePassword()
            
        case .editCardDetails:
            EditCardDetails()
            
        case .promotion:
            PromotionsScreen()
            
        case .about:
            AboutScreen()
            
        case .help:
            HelpsScreen()
            
        case .login:
            LoginScreen()
            
        case .forgotPassword:
            ForgotPasswordView()
            
        case .registration:
            RegisterScreen()
            
        case .landingPage:
            LandingScreen()
        }
    }
}
