//
//  AuthManager.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 21/03/26.
//

import SwiftUI

final class AuthManager {
    
    static let shared = AuthManager()
    
    @AppStorage("customerId") var customerId: String = ""
    @AppStorage("token") var token: String = ""
    @AppStorage("customerName") var customerName: String = ""
    @AppStorage("email") var email: String = ""
    @AppStorage("bookingID") var bookingID: String = ""

    // MARK: - Active trip geometry
    //
    // `client_last_book` and `get_bookdatatoclient` both return the pickup and
    // destination as text only — no coordinates. Without these the tracking map
    // has nothing to draw a route to after a relaunch, so the app remembers what
    // it already knew at booking time.

    @AppStorage("activePickupLat") var activePickupLat: Double = 0
    @AppStorage("activePickupLng") var activePickupLng: Double = 0
    @AppStorage("activeDropLat") var activeDropLat: Double = 0
    @AppStorage("activeDropLng") var activeDropLng: Double = 0
    @AppStorage("activeFareText") var activeFareText: String = ""
    @AppStorage("activeDistanceText") var activeDistanceText: String = ""

    var activePickupCoordinate: Coordinate? {
        Coordinate(latitude: activePickupLat, longitude: activePickupLng)
    }

    var activeDropCoordinate: Coordinate? {
        Coordinate(latitude: activeDropLat, longitude: activeDropLng)
    }

    func saveActiveTrip(
        pickupLat: Double,
        pickupLng: Double,
        dropLat: Double,
        dropLng: Double,
        fareText: String,
        distanceText: String
    ) {
        activePickupLat = pickupLat
        activePickupLng = pickupLng
        activeDropLat = dropLat
        activeDropLng = dropLng
        activeFareText = fareText
        activeDistanceText = distanceText
    }
    
    private init() {}
    
    var isLoggedIn: Bool {
        !customerId.isEmpty
    }
    
    func saveLogin(customerId: String, token: String?, customerName: String?, email: String?) {
        self.customerId = customerId
        self.token = token ?? ""
        self.customerName = customerName ?? ""
        self.email = email ?? ""
    }
    
    func logout() {
        customerId = ""
        token = ""
        customerName = ""
        email = ""
        bookingID = ""

        saveActiveTrip(
            pickupLat: 0,
            pickupLng: 0,
            dropLat: 0,
            dropLng: 0,
            fareText: "",
            distanceText: ""
        )
    }
}
