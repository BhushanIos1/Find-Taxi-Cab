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
        
        setupNotifications(application)
        
        Messaging.messaging().delegate = self
        
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

struct MapAPIKey {
    static let apiKey = "AIzaSyCRNoYcfxw8v8YOT35Z4BRhK-6J22-Qv-Y"
}
