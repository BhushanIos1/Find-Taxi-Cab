//
//  PermissionScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 26/02/26.
//

import SwiftUI

struct PermissionScreen: View {
    
    @EnvironmentObject
    private var launchManager: AppLaunchManager
    
    @EnvironmentObject
    var router: AppRouter
    
    let items = [
        ("notificationPermission",
         "Grant Notifications",
         "Receive trip alerts, messages and announcements in your Inbox."),
        ("locationPermission",
         "Allow Location",
         "We collect your geo-location to identify your current location and provide accurate taxi booking and pickup services. Your location information will not be shared with any third party without your consent."),
        ("filePermission",
         "Allow Phone Storage",
         "You may download receipts to the mobile phone.")
    ]
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    ForEach(items.indices, id: \.self) { index in
                        
                        PermissionListCell(
                            icon: items[index].0,
                            title: items[index].1,
                            subtitle: items[index].2
                        )
                    }
                }
                .padding(20)
            }
            
        }
        .safeAreaInset(edge: .bottom) {
            bottomSection
        }
        .background(Color(.systemGroupedBackground))
        .appNavigationBar(
            title: Bundle.main.appName,
            leading: .none
        )
    }
}

private extension PermissionScreen {
    
    var bottomSection: some View {
        
        VStack(spacing: 20) {
            
            Text("You may manage the app permissions within your device settings when needed.")
                .font(AppFont.font(.regular, size: 14))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button {
                
                Task {
                    
                    let granted =
                    await PermissionManager.shared
                        .requestAllPermissions()
                    
                    print("All granted:", granted)
                    
                    if granted {
                        launchManager.markPermissionCompleted()
                        
                        router.push(.home)
                    }
                }
                
            } label: {
                
                Text("CONFIRM")
                    .primaryButtonStyle()
            }
        }
        .padding(25)
    }
}

struct PermissionListCell: View {
    
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        
        HStack(spacing: 18) {
            
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 14) {
                
                Text(title)
                    .font(AppFont.font(.medium, size: 18))
                
                Text(subtitle)
                    .font(AppFont.font(.regular, size: 14))
            }
            
            Spacer()
        }
        .padding(18)
        .cardStyle()
    }
}

#Preview {
    PermissionScreen()
}
