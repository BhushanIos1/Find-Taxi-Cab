//
//  RegisterScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 28/02/26.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct RegisterScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @EnvironmentObject
    private var toastManager: ToastManager
    
    @State private var name = ""
    @State private var nameError: String?
    
    @State private var email = ""
    @State private var emailError: String?
    
    @State private var phone = ""
    @State private var phoneError: String?
    
    @State private var password = ""
    @State private var passwordError: String?
    
    @State private var address = ""
    
    @State private var postCard = ""
    
    @State private var cardNumber = ""
    
    @State private var nameOnCard = ""
    
    @State private var month = ""
    @State private var year = ""
    
    @StateObject
    private var viewModel = RegisterViewModel()
    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 0) {
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 22) {
                        AppTextField(title: "Name", text: $name, error: nameError,
                                     foregroundColor: Color(uiColor: .label))
                        AppTextField(title: "Email", text: $email, error: emailError, keyboard: .emailAddress,
                                     foregroundColor: Color(uiColor: .label))
                        AppTextField(title: "Phone Number", text: $phone, error: phoneError, keyboard: .phonePad,
                                     foregroundColor: Color(uiColor: .label))
                        AppPasswordField(title: "Password", password: $password, error: passwordError,
                                         foregroundColor: Color(uiColor: .label))
                        AppTextField(title: "Address", text: $address, error: nil,
                                     foregroundColor: Color(uiColor: .label))
                        AppTextField(title: "Post Card", text: $postCard, error: nil,
                                     foregroundColor: Color(uiColor: .label))
                        AppTextField(title: "Card Number", text: $cardNumber, error: nil, keyboard: .numberPad,
                                     foregroundColor: Color(uiColor: .label))
                        AppTextField(title: "Name On Card", text: $nameOnCard, error: nil,
                                     foregroundColor: Color(uiColor: .label))
                        
                        ExpiryDateField(month: $month, year: $year)
                    }
                    .padding(.vertical, 25)
                    .padding(.horizontal, 20)
                }
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
        .safeAreaInset(edge: .bottom) {
            bottomSection
        }
        .appNavigationBar(
            title: "Sign Up",
            leading: .back) {
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
                        router.replaceCurrent(with: .login)
                    }
                    
                case .failure(let message):
                    
                    toastManager.showToast(
                        type: .error,
                        title: "Registration Failed",
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

private extension RegisterScreen {
    
    var bottomSection: some View {
        
        Button {
            
            var isValid = true
            
            //            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            //                nameError = "Name is required"
            //            } else {
            //                nameError = nil
            //            }
            
            if email.isEmpty {
                emailError = "Email is required"
                isValid = false
            } else if !ValidationHelper.isValidEmail(email) {
                emailError = "Enter valid email"
                isValid = false
            } else {
                emailError = nil
            }
            
            if phone.isEmpty {
                phoneError = "Phone is required"
                isValid = false
            } else {
                phoneError = nil
            }
            
            if password.isEmpty {
                passwordError = "Password required"
                isValid = false
            } else {
                passwordError = nil
            }
            
            guard isValid else { return }
            
            viewModel.register(email: email, phone: phone, password: password, cardNumber: cardNumber, router: router)
        } label: {
            
            Text("SIGN UP")
                .primaryButtonStyle()
        }
        .padding(20)
    }
}

#Preview {
    RegisterScreen()
}
