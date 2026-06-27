//
//  ChangePassword.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 02/03/26.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct ChangePassword: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @EnvironmentObject
    private var toastManager: ToastManager
    
    @State private var newPassword = ""
    @State private var newPasswordError: String?
    
    @State private var confirmNewPassword = ""
    @State private var confirmNewPasswordError: String?
    
    @StateObject
    private var viewModel = LoginViewModel()
    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 0) {
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 22) {
                        
                        AppPasswordField(title: "New Password", password: $newPassword, error: newPasswordError,
                                         foregroundColor: Color(uiColor: .label))
                        
                        AppPasswordField(title: "Confirm New Password", password: $confirmNewPassword, error: confirmNewPasswordError,
                                         foregroundColor: Color(uiColor: .label))
                        
                        bottomSection
                            .padding(.top, 20)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
            }
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                
                LoadingIndicator(
                    animation: .circleTrim,
                    color: AppColors.primaryYellow,
                    size: .medium,
                    speed: .normal
                )
            }
        }
        .appNavigationBar(
            title: "Change Password",
            leading: .back) {
                router.pop()
            }
            .onChange(of: viewModel.loginState) { state in
                
                guard let state else { return }
                
                switch state {
                    
                case .success(let message):
                    
                    toastManager.showToast(
                        type: .success,
                        title: "Success",
                        subtitle: message
                    )
                    
                    viewModel.errorMessage = nil
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        AppState.shared.logout()
                        router.popToRoot()
                    }
                    
                case .failure(let message):
                    
                    toastManager.showToast(
                        type: .error,
                        title: "Failed",
                        subtitle: message
                    )
                }
                
                DispatchQueue.main.async {
                    viewModel.loginState = nil
                }
            }
            .overlay(
                GlobalToastView()
                    .environmentObject(toastManager)
            )
    }
}

private extension ChangePassword {
    
    var bottomSection: some View {
        
        Button {
            validate()
        } label: {
            
            Text("UPDATE")
                .primaryButtonStyle()
        }
    }
    
    private func validate() {
        
        var isValid = true
        
        if newPassword.isEmpty {
            newPasswordError = "New Password is required"
            isValid = false
        } else {
            newPasswordError = nil
        }
        
        if confirmNewPassword.isEmpty {
            confirmNewPasswordError = "Please confirm your new password"
            isValid = false
        } else {
            confirmNewPasswordError = nil
        }
        
        if !newPassword.isEmpty,
           !confirmNewPassword.isEmpty,
           newPassword != confirmNewPassword {
            
            isValid = false
            confirmNewPasswordError = "New Password and Confirm Password must match"
        }
        
        guard isValid else { return }
        
        viewModel.changePassword(password: newPassword,
                                 router: router)
    }
}

#Preview {
    ChangePassword()
}
