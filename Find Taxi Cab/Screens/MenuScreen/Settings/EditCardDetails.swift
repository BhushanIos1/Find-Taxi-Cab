//
//  EditCardDetails.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 02/03/26.
//

import SwiftUI
import SwiftfulLoadingIndicators

/// Settings ▸ Edit Credit Card — Android's `AddCardActivity`.
///
/// Same four inputs and the same `edit_card_detaile` call, with one addition:
/// the form loads the card already on file so the customer can see and amend it
/// rather than starting from a blank screen every time.
struct EditCardDetails: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @EnvironmentObject
    private var toastManager: ToastManager
    
    @State private var cardNumber = ""
    @State private var cardNumberError: String?
    
    @State private var nameOnCard = ""
    @State private var nameOnCardError: String?
    
    @State private var cvv = ""
    
    @State private var month = ""
    @State private var year = ""
    
    @StateObject
    private var viewModel = CardViewModel()
    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 0) {
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 22) {
                        
                        AppTextField(title: "Card Number", text: $cardNumber, error: cardNumberError, keyboard: .numberPad,
                                     foregroundColor: Color(uiColor: .label))
                        
                        ExpiryDateField(month: $month, year: $year)
                        
                        AppTextField(title: "CVV", text: $cvv, error: nil, keyboard: .numberPad,
                                     foregroundColor: Color(uiColor: .label))
                        
                        AppTextField(title: "Card Holder Name", text: $nameOnCard, error: nameOnCardError,
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
            .onAppear {
                viewModel.loadCardDetails()
            }
            .onChange(of: viewModel.cardDetails) { card in
                
                guard let card else { return }
                
                // Only fill blanks — never stamp over something being typed.
                if cardNumber.isEmpty { cardNumber = card.card ?? "" }
                if month.isEmpty { month = card.month ?? "" }
                if year.isEmpty { year = card.year ?? "" }
                if nameOnCard.isEmpty { nameOnCard = card.cardHolderName ?? "" }
            }
            .onChange(of: viewModel.updateState) { state in
                
                guard let state else { return }
                
                switch state {
                    
                case .success(let message):
                    
                    toastManager.showToast(
                        type: .success,
                        title: "Success",
                        subtitle: message
                    )
                    
                    // Android finishes straight back to MainActivity.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
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
                    viewModel.updateState = nil
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
            submit()
        } label: {
            
            Text("UPDATE CREDIT CARD")
                .primaryButtonStyle()
        }
    }
    
    /// `AddCardActivity.onViewClicked()` — card number and holder name are
    /// required, and the expiry has to have been picked.
    func submit() {
        
        var isValid = true
        
        if cardNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            cardNumberError = "Card number is required"
            isValid = false
        } else {
            cardNumberError = nil
        }
        
        if nameOnCard.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            nameOnCardError = "Card holder name is required"
            isValid = false
        } else {
            nameOnCardError = nil
        }
        
        if month.isEmpty || year.isEmpty {
            
            toastManager.showToast(
                type: .error,
                title: "Invalid Expiry",
                subtitle: "Please select the card expiry month and year."
            )
            
            isValid = false
        }
        
        guard isValid else { return }
        
        viewModel.updateCard(
            cardNumber: cardNumber,
            cardHolderName: nameOnCard,
            month: month,
            year: year,
            cvv: cvv
        )
    }
}
