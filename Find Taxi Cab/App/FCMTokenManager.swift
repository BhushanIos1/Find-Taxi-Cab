//
//  FCMTokenManager.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 20/06/26.
//

import SwiftUI
import FirebaseMessaging

/// Owns the FCM token end to end: local storage plus registering it with the backend.
/// Android does this from a single call site (`SplashActivity.updateToken()`, only
/// when the launch resolves to an already-logged-in user), posting
/// `{client_id, token}` to `api/update_clienttoken`. Here every path that obtains a
/// token (initial fetch, rotation, manual refresh) funnels through `updateToken(_:)`,
/// which syncs to the server whenever a customer session exists — so a token refresh
/// mid-session gets synced too, which Android's own `onNewToken()` doesn't do.
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
                self.updateToken(token)
                completion?(token)
            } else {
                completion?(nil)
            }
        }
    }

    /// Stores the token locally and, if a customer is logged in, pushes it to the
    /// server right away.
    func updateToken(_ token: String) {
        storedToken = token
        registerWithServerIfLoggedIn()
    }

    /// Posts `{client_id, token}` to `api/update_clienttoken` — same endpoint and
    /// parameters as the Android app's `updateToken()`. No-ops silently when there's
    /// no active session.
    func registerWithServerIfLoggedIn() {

        guard let token, AuthManager.shared.isLoggedIn else { return }

        Task {
            do {
                let response: CommonResponse = try await APIClient.shared.request(
                    CustomerAPI.updateFCMToken(token: token),
                    responseType: CommonResponse.self
                )
                print("✅ FCM TOKEN SYNCED:", response.result ?? "")
            } catch {
                print("❌ FCM TOKEN SYNC ERROR:", error)
            }
        }
    }

    func clearToken() {
        storedToken = ""
    }
}
