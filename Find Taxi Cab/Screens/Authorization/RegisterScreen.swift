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
    @State private var addressError: String?
    
    @State private var postCard = ""
    @State private var postCardError: String?
    
    @State private var cardNumber = ""
    @State private var cardNumberError: String?
    
    @State private var nameOnCard = ""
    @State private var nameOnCardError: String?
    
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
                        AppTextField(title: "Address", text: $address, error: addressError,
                                     foregroundColor: Color(uiColor: .label))
                        AppTextField(title: "Postal Code", text: $postCard, error: postCardError,
                                     foregroundColor: Color(uiColor: .label))
                        AppTextField(title: "Card Number", text: $cardNumber, error: cardNumberError, keyboard: .numberPad,
                                     foregroundColor: Color(uiColor: .label))
                        AppTextField(title: "Name On Card", text: $nameOnCard, error: nameOnCardError,
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
            submit()
        } label: {
            
            Text("SIGN UP")
                .primaryButtonStyle()
        }
        .padding(20)
    }
    
    /// Mirrors `RegisterActivity.validate()` — every field on this form is
    /// required over on Android, and the card trio has to be complete or the
    /// customer ends up registered with nothing `get_card_details` can return.
    func submit() {
        
        var isValid = true
        
        func check(_ value: String, _ message: String) -> String? {
            
            guard value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return nil
            }
            
            isValid = false
            return message
        }
        
        nameError = check(name, "Name is required")
        
        if email.isEmpty {
            emailError = "Email is required"
            isValid = false
        } else if !ValidationHelper.isValidEmail(email) {
            emailError = "Enter valid email"
            isValid = false
        } else {
            emailError = nil
        }
        
        phoneError = check(phone, "Phone is required")
        
        if password.isEmpty {
            passwordError = "Password required"
            isValid = false
        } else if password.count < 6 {
            passwordError = "Password must be at least 6 characters"
            isValid = false
        } else {
            passwordError = nil
        }
        
        addressError = check(address, "Address is required")
        postCardError = check(postCard, "Postal code is required")
        cardNumberError = check(cardNumber, "Card number is required")
        nameOnCardError = check(nameOnCard, "Name on card is required")
        
        // The expiry pickers have nowhere to show an inline error, so this one
        // surfaces the way Android does — as a toast.
        if month.isEmpty || year.isEmpty {
            
            toastManager.showToast(
                type: .error,
                title: "Invalid Expiry",
                subtitle: "Please select the card expiry month and year."
            )
            
            isValid = false
        }
        
        guard isValid else { return }
        
        viewModel.register(
            name: name,
            email: email,
            phone: phone,
            password: password,
            address: address,
            postalCode: postCard,
            cardHolderName: nameOnCard,
            cardNumber: cardNumber,
            cardMonth: month,
            cardYear: year,
            router: router
        )
    }
}

#Preview {
    RegisterScreen()
}
