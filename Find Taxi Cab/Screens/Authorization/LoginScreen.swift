//
//  LoginScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 28/02/26.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct LoginScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @EnvironmentObject
    private var toastManager: ToastManager
    
    @State private var email = ""
    @State private var emailError: String?
    
    @State private var password = ""
    @State private var passwordError: String?
    
    @StateObject
    private var viewModel = LoginViewModel()
    
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
                    
                    formSection
                    
                    actionSection
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
            title: "Sign In",
            leading: .back
        ) {
            router.pop()
        }
        .onAppear {
            FCMTokenManager.shared.refreshToken { token in
                print("Fresh FCM:", token ?? "nil")
            }
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    router.push(.home)
                }
                
            case .failure(let message):
                
                toastManager.showToast(
                    type: .error,
                    title: "Login Failed",
                    subtitle: message
                )
            }
            
            DispatchQueue.main.async {
                viewModel.loginState = nil
            }
        }
        .overlay(GlobalToastView().environmentObject(toastManager))
    }
}

private extension LoginScreen {
    
    var formSection: some View {
        
        VStack(spacing: 14) {
            
            AppTextField(
                title: "Email",
                text: $email,
                error: emailError,
                keyboard: .emailAddress,
                foregroundColor: .black
            )
            .padding(10)
            .background(.white)
            
            AppPasswordField(
                title: "Password",
                password: $password,
                error: passwordError,
                foregroundColor: .black
            )
            .padding(10)
            .background(.white)
        }
    }
}

private extension LoginScreen {
    
    var actionSection: some View {
        
        VStack(spacing: 40) {
            
            Button {
                router.push(.forgotPassword)
            } label: {
                Text("FORGOT PASSWORD?")
                    .font(AppFont.font(.medium, size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Button {
                validateAndLogin()
            } label: {
                Text("SIGN IN")
                    .primaryButtonStyle()
            }
        }
        .padding(.top, 25)
    }
    
    private func validateAndLogin() {
        
        var isValid = true
        
        if email.isEmpty {
            emailError = "Email is required"
            isValid = false
        } else if !ValidationHelper.isValidEmail(email) {
            emailError = "Enter valid email"
            isValid = false
        } else {
            emailError = nil
        }
        
        if password.isEmpty {
            passwordError = "Password required"
            isValid = false
        } else {
            passwordError = nil
        }
        
        guard isValid else { return }
        
        viewModel.login(email: email,
                        password: password,
                        router: router)
    }
}

#Preview {
    LoginScreen()
}
