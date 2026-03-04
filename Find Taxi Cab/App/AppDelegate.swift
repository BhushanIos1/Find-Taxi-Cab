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

class AppDelegate: NSObject,
                   UIApplicationDelegate,
                   UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        UNUserNotificationCenter.current().delegate = self
        
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardToolbarManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.toolbarConfiguration.tintColor = UIColor.black
        IQKeyboardToolbarManager.shared.toolbarConfiguration.previousNextDisplayMode = .alwaysShow
        return true
    }
}
