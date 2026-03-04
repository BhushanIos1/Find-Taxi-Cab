//
//  SettingScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI

struct SettingScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                
                LazyVStack(spacing: 5) {
                    
                    settingsRow(title: "Change Password") {
                        router.push(.changePassword)
                    }
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    settingsRow(title: "Edit Credit Card") {
                        router.push(.editCardDetails)
                    }
                    
                    Divider()
                        .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
        }
        .appNavigationBar(
            title: "Settings",
            leading: .back) {
                router.pop()
            }
    }
    
    @ViewBuilder
    private func settingsRow(
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        
        Button(action: action) {
            
            HStack {
                
                Text(title)
                    .font(AppFont.font(.regular, size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

#Preview {
    SettingScreen()
}
