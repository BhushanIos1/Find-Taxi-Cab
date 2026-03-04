//
//  LoginScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 28/02/26.
//

import SwiftUI

struct LoginScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @State private var email = ""
    @State private var emailError: String?
    
    @State private var password = ""
    @State private var passwordError: String?
    
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
        }
        .appNavigationBar(
            title: "Sign In",
            leading: .back
        ) {
            router.pop()
        }
    }
}

private extension LoginScreen {
    
    var formSection: some View {
        
        VStack(spacing: 14) {
            
            AppTextField(
                title: "Email",
                text: $email,
                error: emailError,
                keyboard: .emailAddress
            )
            .padding(10)
            .background(.white)
            
            AppPasswordField(
                title: "Password",
                password: $password,
                error: passwordError
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
        
//        emailError = email.isEmpty
//        ? "Email required"
//        : (!ValidationHelper.isValidEmail(email)
//           ? "Invalid email"
//           : nil)
//        
//        passwordError = password.isEmpty
//        ? "Password required"
//        : nil
//        
//        guard emailError == nil,
//              passwordError == nil else { return }
        
        print("✅ Login Success")
        router.push(.home)
    }
}

#Preview {
    LoginScreen()
}
