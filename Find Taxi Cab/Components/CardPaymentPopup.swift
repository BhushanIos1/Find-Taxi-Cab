//
//  CardPaymentPopup.swift
//  Find Taxi Cab
//
//  Created by Claude on 11/09/26.
//

import SwiftUI

struct CardPaymentPopup: View {

    @Environment(\.colorScheme) private var colorScheme

    let card: CardDetails
    let isPaying: Bool
    let couponMessage: String?

    var onApplyCoupon: (_ code: String) -> Void
    var onPay: (_ card: String, _ month: String, _ year: String, _ cvc: String, _ code: String) -> Void
    var onCancel: () -> Void

    @State private var cardNumber = ""
    @State private var month = ""
    @State private var year = ""
    @State private var cvc = ""
    @State private var couponCode = ""

    /// Android blocks Pay Now on an empty CVV.
    private var canPay: Bool {
        !isPaying && !cvc.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 26) {

            underlinedField(text: $cardNumber, placeholder: "Card Number", keyboard: .numberPad)

            HStack(spacing: 20) {

                underlinedField(text: $month, placeholder: "MM", keyboard: .numberPad)
                underlinedField(text: $year, placeholder: "YYYY", keyboard: .numberPad)
                underlinedField(text: $cvc, placeholder: "CVV", keyboard: .numberPad)
            }

            couponRow

            if let couponMessage {
                Text(couponMessage)
                    .font(AppFont.font(.regular, size: 13))
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 14) {

                actionButton(title: isPaying ? "Paying…" : "Pay Now", enabled: canPay) {
                    onPay(cardNumber, month, year, cvc, couponCode)
                }

                actionButton(title: "Cancel", enabled: !isPaying) {
                    onCancel()
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
        )
        .padding(.horizontal, 20)
        .onAppear {
            cardNumber = card.card ?? ""
            month = card.month ?? ""
            year = card.year ?? ""
        }
    }
}

private extension CardPaymentPopup {

    var couponRow: some View {

        HStack(spacing: 14) {

            underlinedField(text: $couponCode, placeholder: "Coupon", keyboard: .default)

            Button {
                onApplyCoupon(couponCode)
            } label: {
                Text("Apply")
                    .font(AppFont.font(.medium, size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(AppColors.primaryYellow)
            }
            .frame(maxWidth: 150)
        }
    }

    func underlinedField(
        text: Binding<String>,
        placeholder: String,
        keyboard: UIKeyboardType
    ) -> some View {

        VStack(spacing: 6) {

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .font(AppFont.font(.semiBold, size: 18))
                .foregroundColor(colorScheme == .dark ? .white : .black)

            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.45))
        }
    }

    func actionButton(
        title: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {
            Text(title)
                .font(AppFont.font(.medium, size: 19))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(enabled ? AppColors.primaryYellow : AppColors.primaryYellow.opacity(0.5))
        }
        .disabled(!enabled)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.45).ignoresSafeArea()

        CardPaymentPopup(
            card: CardDetails(card: "4242424242424242", month: "12", year: "2027"),
            isPaying: false,
            couponMessage: nil,
            onApplyCoupon: { _ in },
            onPay: { _, _, _, _, _ in },
            onCancel: {}
        )
    }
}
