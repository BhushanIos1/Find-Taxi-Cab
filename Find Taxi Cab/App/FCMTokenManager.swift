//
//  FCMTokenManager.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 20/06/26.
//

import SwiftUI
import FirebaseMessaging

final class FCMTokenManager: ObservableObject {
    
    static let shared = FCMTokenManager()
    
    @AppStorage("fcmToken") private var storedToken: String = ""
    
    private init() {}
    
    var token: String? {
        storedToken.isEmpty ? nil : storedToken
    }
    
    func getToken() -> String? {
        token
    }
    
    func refreshToken(completion: ((String?) -> Void)? = nil) {
        Messaging.messaging().token { [weak self] token, error in
            
            guard let self = self else { return }
            
            if let token = token {
                self.storedToken = token
                completion?(token)
            } else {
                completion?(nil)
            }
        }
    }
    
    func updateToken(_ token: String) {
        storedToken = token
    }
    
    func clearToken() {
        storedToken = ""
    }
}
