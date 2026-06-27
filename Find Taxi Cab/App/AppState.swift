//
//  AppState.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 20/06/26.
//

import SwiftUI

@MainActor
final class AppState: ObservableObject {
    
    static let shared = AppState()
    
    @Published var isLoggedIn: Bool = false
    
    private init() {
        restoreSession()
    }
    
    func restoreSession() {
        isLoggedIn = AuthManager.shared.isLoggedIn
    }
    
    func login(customerId: String, token: String?, customerName: String?, email: String?) {
        AuthManager.shared.saveLogin(customerId: customerId, token: token, customerName: customerName, email: email)
        isLoggedIn = true
    }
    
    func logout() {
        AuthManager.shared.logout()
        isLoggedIn = false
    }
}

