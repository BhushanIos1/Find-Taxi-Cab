//
//  ChangePassword.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 02/03/26.
//

import SwiftUI

struct ChangePassword: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @State private var newPassword = ""
    @State private var newPasswordError: String?
    
    @State private var confirmNewPassword = ""
    @State private var confirmNewPasswordError: String?
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 22) {
                    
                    AppPasswordField(title: "New Password", password: $newPassword, error: newPasswordError)
                    
                    AppPasswordField(title: "Confirm New Password", password: $confirmNewPassword, error: confirmNewPasswordError)
                    
                    bottomSection
                        .padding(.top, 20)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
        }
        .appNavigationBar(
            title: "Change Password",
            leading: .back) {
                router.pop()
            }
    }
}

private extension ChangePassword {
    
    var bottomSection: some View {
        
        Button {
            router.pop()
        } label: {
            
            Text("UPDATE")
                .primaryButtonStyle()
        }
    }
}

#Preview {
    ChangePassword()
}
