//
//  Find_Taxi_CabApp.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 25/02/26.
//

import SwiftUI

@main
struct Find_Taxi_CabApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    @StateObject
    private var launchManager = AppLaunchManager()
    
    @StateObject
    private var router = AppRouter()
    
    @StateObject
    private var appState = AppState.shared
    
    @StateObject
    private var toastManager = ToastManager()
        
    var body: some Scene {
        
        WindowGroup {
            NavigationStack(path: $router.path) {
                
                RootView()
                    .navigationDestination(
                        for: AppRoute.self
                    ) { route in
                        RouteBuilder.build(route)
                    }
            }
            
            .environmentObject(router)
            .environmentObject(launchManager)
            .environmentObject(appState)
            .environmentObject(toastManager)
        }
    }
}

struct RootView: View {
    
    @EnvironmentObject
    private var launchManager: AppLaunchManager
    
    @EnvironmentObject
    private var appState: AppState
    
    var body: some View {
        
        if launchManager.shouldShowPermission {
            PermissionScreen()
        } else if appState.isLoggedIn {
            HomeScreen()
        } else {
            LandingScreen()
        }
    }
}
