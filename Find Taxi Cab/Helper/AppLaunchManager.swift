//
//  AppLaunchManager.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 26/02/26.
//

import SwiftUI

final class AppLaunchManager: ObservableObject {

    @AppStorage("permission_completed")
    private var permissionCompleted: Bool = false

    var shouldShowPermission: Bool {
        !permissionCompleted
    }

    func markPermissionCompleted() {
        permissionCompleted = true
    }
}
