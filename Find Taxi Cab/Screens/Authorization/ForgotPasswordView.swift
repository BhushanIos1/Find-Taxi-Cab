//
//  ForgotPasswordView.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 28/02/26.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct ForgotPasswordView: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @EnvironmentObject
    private var toastManager: ToastManager
    
    @State private var email = ""
    @State private var emailError: String?
    
    @StateObject
    private var viewModel = RegisterViewModel()
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                
                VStack {
                    
                    Image("loginLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .padding(.top, 160)
                        .padding(.bottom, 25)
                    
                    AppTextField(
                        title: "Email",
                        text: $email,
                        error: emailError,
                        keyboard: .emailAddress,
                        foregroundColor: .black
                    )
                    .padding(10)
                    .background(.white)
                    
                    Button {
                        validateAndLogin()
                    } label: {
                        Text("SEND RESET LINK")
                            .primaryButtonStyle()
                    }
                    .padding(.top, 25)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
            }
            
            if viewModel.isLoading {
                
                Color.clear
                    .contentShape(Rectangle())
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
            title: "Forgot Password",
            leading: .back
        ) {
            router.pop()
        }
        .onChange(of: viewModel.registrationState) { state in
            
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
                    router.pop()
                }
                
            case .failure(let message):
                
                toastManager.showToast(
                    type: .error,
                    title: "Failed",
                    subtitle: message
                )
            }
            
            DispatchQueue.main.async {
                viewModel.registrationState = nil
            }
        }
        .overlay(GlobalToastView().environmentObject(toastManager))
    }
}

private extension ForgotPasswordView {
    
    private func validateAndLogin() {
        
        emailError = email.isEmpty
        ? "Email required"
        : (!ValidationHelper.isValidEmail(email)
           ? "Invalid email"
           : nil)
        
        guard emailError == nil else { return }
        
        viewModel.forgotPassword(email: email, router: router)
    }
}

#Preview {
    ForgotPasswordView()
}
