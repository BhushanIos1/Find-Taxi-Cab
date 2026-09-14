//
//  AppDelegate.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 26/02/26.
//

import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager
import GoogleMaps
import GooglePlaces
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject,
                   UIApplicationDelegate,
                   UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        setupNotifications(application)
        
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardToolbarManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.toolbarConfiguration.tintColor = .label
        IQKeyboardToolbarManager.shared.toolbarConfiguration.previousNextDisplayMode = .alwaysShow
        
        GMSServices.provideAPIKey(MapAPIKey.apiKey)
        GMSPlacesClient.provideAPIKey(MapAPIKey.apiKey)
        return true
    }
}

private extension AppDelegate {
    
    func setupNotifications(_ application: UIApplication) {
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            print("Permission granted: \(granted)")
            
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
}

extension AppDelegate {

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {

        Messaging.messaging().apnsToken = deviceToken

        print("✅ APNS Token Received")

        Messaging.messaging().token { token, error in

            if let token {
                print("🔥 FCM Token:", token)
                FCMTokenManager.shared.updateToken(token)
            }

            if let error {
                print("❌ FCM Error:", error)
            }
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ APNS Registration Failed:", error)
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        print("Updated FCM Token: \(token)")
        
        // ✅ Single source of truth
        FCMTokenManager.shared.updateToken(token)
    }
}

extension AppDelegate {

    /// Data-only / silent pushes (`content-available`, no `aps.alert`) land here in
    /// every app state — foreground, background, or freshly launched from a push.
    /// This is the direct counterpart of `MyFireBaseMessagingService.onMessageReceived()`
    /// on Android, which is why every status-driven push (`book_accept`,
    /// `book_pickcustomer`, `nodriver`, `book_cancelled`, `book_complete`, `block`)
    /// is sent silent rather than as a visible alert.
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        NotificationManager.shared.handle(userInfo: userInfo)
        completionHandler(.newData)
    }

    /// Fires only for pushes that carry a visible `aps.alert` while the app is in the
    /// foreground (e.g. a combined notification+data payload).
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {

        let userInfo = notification.request.content.userInfo

        print("🔔 FOREGROUND PUSH")

        NotificationManager.shared.handle(userInfo: userInfo)
        completionHandler([.banner, .list, .sound])
    }

    /// User tapped a visible notification (banner or from Notification Center).
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        print("🔔 NOTIFICATION TAPPED")

        NotificationManager.shared.handle(userInfo: userInfo)
        completionHandler()
    }
}

struct MapAPIKey {
    static let apiKey = "AIzaSyCRNoYcfxw8v8YOT35Z4BRhK-6J22-Qv-Y"

    /// Directions API is billed separately from Maps SDK, so it gets its own key
    /// — same split the driver app uses.
    static let directionApiKey = "AIzaSyA9hS0Vp12mgfr3xLU1kVk7Gg-Q8cgWraE"
}
