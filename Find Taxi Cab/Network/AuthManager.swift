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
    }
}
