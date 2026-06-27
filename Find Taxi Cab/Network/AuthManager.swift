//
//  AuthManager.swift
//  Find Taxi Cab Driver
//
//  Created by Bhushan Kumar on 21/03/26.
//

import SwiftUI

final class AuthManager {
    
    static let shared = AuthManager()
    
    @AppStorage("driverId") var driverId: String = ""
    @AppStorage("token") var token: String = ""
    @AppStorage("workStatus") var workStatus: String = ""
    
    private init() {}
    
    var isLoggedIn: Bool {
        !driverId.isEmpty
    }
    
    func saveLogin(driverId: String, token: String?, status: String?) {
        self.driverId = driverId
        self.token = token ?? ""
        self.workStatus = status ?? ""
    }
    
    func logout() {
        driverId = ""
        token = ""
        workStatus = ""
        FCMTokenManager.shared.clearToken()
    }
}
