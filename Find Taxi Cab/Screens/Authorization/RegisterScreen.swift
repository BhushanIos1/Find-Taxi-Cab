//
//  RegisterScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 28/02/26.
//

import SwiftUI

struct RegisterScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
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
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 22) {
                    AppTextField(title: "Name", text: $name, error: nameError)
                    AppTextField(title: "Email", text: $email, error: emailError, keyboard: .emailAddress)
                    AppTextField(title: "Phone Number", text: $phone, error: phoneError, keyboard: .phonePad)
                    AppPasswordField(title: "Password", password: $password, error: passwordError)
                    AppTextField(title: "Address", text: $address, error: nil)
                    AppTextField(title: "Post Card", text: $postCard, error: nil)
                    AppTextField(title: "Card Number", text: $cardNumber, error: nil, keyboard: .numberPad)
                    AppTextField(title: "Name On Card", text: $nameOnCard, error: nil)
                    
                    ExpiryDateField(month: $month, year: $year)
                }
            }
            .padding(.vertical, 25)
            .padding(.horizontal, 20)
        }
        .safeAreaInset(edge: .bottom) {
            bottomSection
        }
        .appNavigationBar(
            title: "Sign Up",
            leading: .back) {
                router.pop()
            }
    }
}

private extension RegisterScreen {
    
    var bottomSection: some View {
        
        Button {
            
            //            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            //                nameError = "Name is required"
            //            } else {
            //                nameError = nil
            //            }
            //
            //            if email.isEmpty {
            //                emailError = "Email is required"
            //            }
            //            else if !ValidationHelper.isValidEmail(email) {
            //                emailError = "Enter valid email address"
            //            }
            //            else {
            //                emailError = nil
            //                print("✅ Email Valid")
            //            }
            router.push(.home)
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
