//
//  ForgotPasswordView.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 28/02/26.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @State private var email = ""
    @State private var emailError: String?
    
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
                        keyboard: .emailAddress
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
        }
        .appNavigationBar(
            title: "Forgot Password",
            leading: .back
        ) {
            router.pop()
        }
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
        
        print("✅ Success")
    }
}

#Preview {
    ForgotPasswordView()
}
