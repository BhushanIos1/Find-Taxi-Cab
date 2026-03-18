//
//  CreditCardView.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 19/03/26.
//

import SwiftUI

struct CreditCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var cardNumber = ""
    @State private var expiryMonth = ""
    @State private var expiryYear = ""
    @State private var cvv = ""
    @State private var coupon = ""
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        
        VStack(spacing: 5) {
            
            // CARD NUMBER
            TextField("Card Number", text: $cardNumber)
                .keyboardType(.numberPad)
                .font(AppFont.font(.semiBold, size: 16))
                .onChange(of: cardNumber) { _ in
                    cardNumber = formatCardNumber(cardNumber)
                }
                .padding()
            
            Divider()
            
            // EXPIRY + CVV
            HStack(spacing: 20) {
                
                TextField("MM", text: $expiryMonth)
                    .keyboardType(.numberPad)
                    .font(AppFont.font(.semiBold, size: 16))
                    .onChange(of: expiryMonth) { _ in
                        expiryMonth = String(expiryMonth.prefix(2))
                    }
                
                TextField("YYYY", text: $expiryYear)
                    .keyboardType(.numberPad)
                    .font(AppFont.font(.semiBold, size: 16))
                    .onChange(of: expiryYear) { _ in
                        expiryYear = String(expiryYear.prefix(4))
                    }
                
                TextField("CVV", text: $cvv)
                    .keyboardType(.numberPad)
                    .font(AppFont.font(.semiBold, size: 16))
                    .onChange(of: cvv) { _ in
                        cvv = String(cvv.prefix(3))
                    }
            }
            .padding()
            
            Divider()
            
            // COUPON
            HStack {
                
                TextField("Coupon", text: $coupon)
                    .font(AppFont.font(.semiBold, size: 16))
                
                Button("Apply") {
                    // Apply coupon logic
                }
                .font(AppFont.font(.medium, size: 18))
                .frame(width: 120, height: 44)
                .background(AppColors.primaryYellow)
                .foregroundColor(.white)
            }
            .padding()
            
            // BUTTONS
            HStack(spacing: 7) {
                
                Button {
                    if validate() {
                        print("Proceed Payment")
                    }
                } label: {
                    Text("Paynow")
                        .font(AppFont.font(.medium, size: 18))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.primaryYellow)
                        .foregroundColor(.white)
                }
                
                Button {
                    // cancel action
                } label: {
                    Text("Cancel")
                        .font(AppFont.font(.medium, size: 18))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.primaryYellow)
                        .foregroundColor(.white)
                }
            }
            .font(AppFont.font(.medium, size: 18))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(colorScheme == .dark
                      ? Color(.systemGray6)
                      : Color(.white))
                .shadow(radius: 10)
        )
        .padding(20)
        .alert(errorMessage, isPresented: $showError) {
            Button("OK", role: .cancel) {}
        }
    }
}

extension CreditCardView {
    
    func formatCardNumber(_ input: String) -> String {
        
        let numbers = input.replacingOccurrences(of: " ", with: "")
        let limited = String(numbers.prefix(16))
        
        var result = ""
        
        for (index, char) in limited.enumerated() {
            if index != 0 && index % 4 == 0 {
                result.append(" ")
            }
            result.append(char)
        }
        
        return result
    }
    
    func validate() -> Bool {
        
        let cleanCard = cardNumber.replacingOccurrences(of: " ", with: "")
        
        if cleanCard.count != 16 {
            return show("Invalid Card Number")
        }
        
        guard let month = Int(expiryMonth), month >= 1, month <= 12 else {
            return show("Invalid Expiry Month")
        }
        
        guard let year = Int(expiryYear), year >= 2024 else {
            return show("Invalid Expiry Year")
        }
        
        if cvv.count != 3 {
            return show("Invalid CVV")
        }
        
        return true
    }
    
    func show(_ message: String) -> Bool {
        errorMessage = message
        showError = true
        return false
    }
}

#Preview {
    CreditCardView()
}
