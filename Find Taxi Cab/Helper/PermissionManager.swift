//
//  PermissionManager.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 26/02/26.
//

import Foundation
import UserNotifications
import CoreLocation
import Photos
import UIKit

enum AppPermission {
    case notification
    case location
    case photos
}

final class PermissionManager: NSObject, ObservableObject {

    static let shared = PermissionManager()

    private let locationManager = CLLocationManager()

    private var locationContinuation:
        CheckedContinuation<Bool, Never>?

    private override init() {
        super.init()
        locationManager.delegate = self
    }
}

extension PermissionManager {

    func requestNotificationPermission() async -> Bool {

        do {
            return try await
            UNUserNotificationCenter.current()
                .requestAuthorization(
                    options: [.alert, .badge, .sound]
                )
        } catch {
            return false
        }
    }
}

extension PermissionManager {

    func requestLocationPermission() async -> Bool {

        let status = locationManager.authorizationStatus

        if status == .authorizedAlways ||
            status == .authorizedWhenInUse {
            return true
        }

        return await withCheckedContinuation { continuation in

            // ✅ Prevent multiple continuation crash
            locationContinuation?.resume(returning: false)

            locationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension PermissionManager: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {

        let status = manager.authorizationStatus

        let granted =
            status == .authorizedAlways ||
            status == .authorizedWhenInUse

        Task { @MainActor [weak self] in
            guard let self else { return }

            self.locationContinuation?
                .resume(returning: granted)

            self.locationContinuation = nil
        }
    }
}

extension PermissionManager {

    func requestPhotoPermission() async -> Bool {

        await withCheckedContinuation { continuation in

            PHPhotoLibrary.requestAuthorization { status in

                continuation.resume(
                    returning:
                        status == .authorized ||
                        status == .limited
                )
            }
        }
    }
}

extension PermissionManager {

    func status(for permission: AppPermission) async -> Bool {

        switch permission {

        case .notification:

            let settings =
            await UNUserNotificationCenter.current()
                .notificationSettings()

            return settings.authorizationStatus == .authorized

        case .location:

            let status = locationManager.authorizationStatus
            return status == .authorizedAlways ||
                   status == .authorizedWhenInUse

        case .photos:

            let status = PHPhotoLibrary.authorizationStatus()
            return status == .authorized ||
                   status == .limited
        }
    }
}

extension PermissionManager {

    func openAppSettings() {

        guard let url =
            URL(string: UIApplication.openSettingsURLString)
        else { return }

        UIApplication.shared.open(url)
    }
}

extension PermissionManager {

    func requestAllPermissions() async -> Bool {

        let notification =
            await requestNotificationPermission()

        let location =
            await requestLocationPermission()

        let photos =
            await requestPhotoPermission()

        return notification && location && photos
    }
}
