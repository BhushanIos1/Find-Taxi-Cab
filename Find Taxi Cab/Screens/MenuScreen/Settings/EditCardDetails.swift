//
//  EditCardDetails.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 02/03/26.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct EditCardDetails: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @EnvironmentObject
    private var toastManager: ToastManager
    
    @State private var cardNumber = ""
    
    @State private var nameOnCard = ""
    
    @State private var month = ""
    @State private var year = ""
    
    @StateObject
    private var viewModel = LoginViewModel()
    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 0) {
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 22) {
                        
                        AppTextField(title: "Card Number", text: $cardNumber, error: nil, keyboard: .numberPad,
                                     foregroundColor: Color(uiColor: .label))
                        
                        ExpiryDateField(month: $month, year: $year)
                        
                        AppTextField(title: "Card Holder Name", text: $nameOnCard, error: nil,
                                     foregroundColor: Color(uiColor: .label))
                        
                        bottomSection
                            .padding(.top, 20)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
            }
            
            if viewModel.isLoading {
                
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
                
                LoadingIndicator(
                    animation: .circleTrim,
                    color: AppColors.primaryYellow,
                    size: .medium,
                    speed: .normal
                )
            }
        }
        .appNavigationBar(
            title: "Update Credit Card",
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

private extension EditCardDetails {
    
    var bottomSection: some View {
        
        Button {
            
            viewModel.updateCardDetails(cardNumber: cardNumber, cardHolder: nameOnCard, month: month, year: year)
        } label: {
            
            Text("UPDATE CREDIT CARD")
                .primaryButtonStyle()
        }
    }
}
