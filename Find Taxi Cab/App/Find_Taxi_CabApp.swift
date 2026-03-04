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
        }
    }
}

struct RootView: View {
    
    @EnvironmentObject
    private var launchManager: AppLaunchManager
    
    var body: some View {
        
        if launchManager.shouldShowPermission {
            
            PermissionScreen()
            
        }
        //        else if !launchManager.isLoggedIn {
        //
        //            RegisterScreen()
        //
        //        }
        else {
            
            LandingScreen() //Home
        }
    }
}
