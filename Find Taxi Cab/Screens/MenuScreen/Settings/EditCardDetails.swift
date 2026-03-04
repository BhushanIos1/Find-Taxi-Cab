//
//  EditCardDetails.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 02/03/26.
//

import SwiftUI

struct EditCardDetails: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @State private var cardNumber = ""
    
    @State private var nameOnCard = ""
    
    @State private var month = ""
    @State private var year = ""
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 22) {
                    
                    AppTextField(title: "Card Number", text: $cardNumber, error: nil, keyboard: .numberPad)
                    
                    ExpiryDateField(month: $month, year: $year)
                    
                    AppTextField(title: "Card Holder Name", text: $nameOnCard, error: nil)
                    
                    bottomSection
                        .padding(.top, 20)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
        }
        .appNavigationBar(
            title: "Update Credit Card",
            leading: .back) {
                router.pop()
            }
    }
}

private extension EditCardDetails {
    
    var bottomSection: some View {
        
        Button {
            router.pop()
        } label: {
            
            Text("UPDATE CREDIT CARD")
                .primaryButtonStyle()
        }
    }
}

#Preview {
    EditCardDetails()
}
