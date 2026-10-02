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

    /// Set whenever the last sync attempt did not land — a dropped connection,
    /// a server hiccup, anything. Persisted (not just in-memory) so a device
    /// that goes fully offline doesn't lose the retry across a relaunch: the
    /// next call to `registerWithServerIfLoggedIn()` — from login, cold
    /// launch, or simply returning to the foreground, all of which already
    /// call it — starts a fresh attempt rather than assuming the old one
    /// eventually landed.
    @AppStorage("fcmTokenSyncPending") private var syncPending: Bool = false

    /// Guards against two overlapping sync attempts — e.g. `.onAppear` and
    /// `.onChange(of: scenePhase)` both firing within the same moment — from
    /// racing each other and both retrying independently.
    private var isSyncing = false

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

    /// Posts the token to the server — retrying on the spot rather than the old
    /// fire-once-and-hope behaviour, which silently dropped the sync on any
    /// blip and left this device (or whichever device just logged in) with no
    /// working push registration until something else happened to call this
    /// again. Three attempts with backoff; if every one fails — a genuinely
    /// offline device — `syncPending` is left set so the very next trigger
    /// (login, launch, foreground) tries again from a clean slate instead of
    /// assuming an old attempt eventually got through.
    func registerWithServerIfLoggedIn() {

        guard let token, AuthManager.shared.isLoggedIn else { return }
        guard !isSyncing else { return }

        isSyncing = true

        Task { [weak self] in

            guard let self else { return }

            defer { self.isSyncing = false }

            let maxAttempts = 3

            for attempt in 1...maxAttempts {

                do {

                    let response: CommonResponse = try await APIClient.shared.request(
                        CustomerAPI.updateFCMToken(token: token),
                        responseType: CommonResponse.self
                    )

                    print("✅ FCM TOKEN SYNCED:", response.result ?? "")
                    self.syncPending = false
                    return

                } catch {

                    print("❌ FCM TOKEN SYNC ERROR (attempt \(attempt)/\(maxAttempts)):", error)

                    if attempt < maxAttempts {
                        // 2s, then 4s — brief enough not to stall a device that
                        // just recovered signal, without hammering a server
                        // that's genuinely down.
                        try? await Task.sleep(for: .seconds(attempt * 2))
                    }
                }
            }

            self.syncPending = true
        }
    }

    func clearToken() {
        storedToken = ""
    }

    /// Awaits a real token rather than racing Firebase's async fetch, which is
    /// what `login()` was doing before: `getToken() ?? "FIREBASE_FCM_TOKEN"` sends
    /// that literal placeholder string to the server as the push token whenever
    /// the real one hasn't arrived yet — the exact situation on a fresh install
    /// (a new device, or the same account signed in somewhere new), since
    /// Firebase mints a token over the network after APNs registration and that
    /// round trip is rarely done before someone can type a password and tap
    /// Login. Nothing ever corrects it afterward: `didReceiveRegistrationToken`
    /// only fires once per install (or on the rare rotation), so once garbage is
    /// on the server for this account, it stays there until the next login.
    ///
    /// Races the real fetch against a timeout instead — normally near-instant
    /// since Firebase caches internally, degrading to "log in without a token
    /// this once" on a genuinely bad connection rather than hanging the button.
    func currentToken(timeout: Duration = .seconds(4)) async -> String? {

        if let token { return token }

        return await withTaskGroup(of: String?.self) { group in

            group.addTask {
                await withCheckedContinuation { continuation in
                    Messaging.messaging().token { token, _ in
                        continuation.resume(returning: token)
                    }
                }
            }

            group.addTask {
                try? await Task.sleep(for: timeout)
                return nil
            }

            let result = await group.next() ?? nil
            group.cancelAll()

            if let result {
                self.updateToken(result)
            }

            return result
        }
    }
}
