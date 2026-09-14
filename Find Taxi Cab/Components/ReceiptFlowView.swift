//
//  ReceiptFlowView.swift
//  Find Taxi Cab
//
//  Created by Claude on 11/09/26.
//

import SwiftUI

/// The two-step settle-up flow, mirroring Android's `InvoiceFragment`:
///
/// 1. **Receipt** — fare breakdown, star rating, comment.
/// 2. **SUBMIT** does *not* submit feedback. It opens the card dialog, carrying
///    the rating and comment with it — or, if no card is on file, refuses and
///    says so (Android's "No Payment Details..." toast).
/// 3. **Pay Now** → `do_payment`, which charges the trip *and* records the
///    rating, comment and tip in the same call.
///
/// The card dialog layers *over* the receipt rather than replacing it, the way
/// Android's `payDialog` sits on top of the still-present invoice fragment.
struct ReceiptFlowView: View {

    let context: ReceiptContext

    /// Called once the flow is done with — paid, skipped, or dismissed.
    var onFinished: () -> Void

    @StateObject private var paymentViewModel = PaymentViewModel()

    @State private var isShowingPayment = false
    @State private var rating = 5
    @State private var comment = ""

    /// The tip the customer typed on the receipt, carried into the card dialog
    /// so `do_payment` charges the figure they were shown.
    @State private var tip = ""
    @State private var errorMessage: String?

    var body: some View {

        ZStack {

            // Backdrop for the receipt itself — tapping outside closes the flow.
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { onFinished() }

            receiptLayer

            if isShowingPayment, let card = paymentViewModel.cardDetails {

                // Second backdrop dims the receipt behind the card dialog, and
                // tapping it steps back to the receipt rather than closing
                // everything — matching Cancel in the dialog.
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { isShowingPayment = false }

                CardPaymentPopup(
                    card: card,
                    isPaying: paymentViewModel.isLoading,
                    couponMessage: paymentViewModel.couponMessage,
                    onApplyCoupon: { code in
                        paymentViewModel.applyCoupon(code: code)
                    },
                    onPay: { card, month, year, cvc, code in
                        paymentViewModel.pay(
                            bookingId: context.bookingId,
                            card: card,
                            month: month,
                            year: year,
                            cvc: cvc,
                            couponCode: code,
                            feedback: comment,
                            rating: rating,
                            driverTip: payableTip,
                            // The same figure the receipt showed, read from the
                            // one function that computes it.
                            amount: ReceiptView.payableAmount(
                                for: context.fare,
                                tipOverride: tipValue
                            )
                        )
                    },
                    onCancel: {
                        isShowingPayment = false
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isShowingPayment)
        .onAppear {
            // Android fetches the card in onViewCreated, before Submit is reachable.
            paymentViewModel.loadCardDetails()
        }
        .onChange(of: paymentViewModel.paymentState) { state in

            guard let state else { return }

            switch state {

            case .paid:
                // Android dismisses both dialogs and returns to MainActivity.
                onFinished()

            case .failed(let message):
                errorMessage = message
                isShowingPayment = false
            }

            paymentViewModel.paymentState = nil
        }
    }
}

private extension ReceiptFlowView {

    var receiptLayer: some View {

        ScrollView(showsIndicators: false) {

            VStack(spacing: 10) {

                ReceiptView(
                    fare: context.fare,
                    onSubmit: handleSubmit,
                    onDismiss: onFinished
                )

                if let errorMessage {
                    Text(errorMessage)
                        .font(AppFont.font(.regular, size: 14))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(.horizontal, 20)
                }
            }
        }
        .frame(maxHeight: 640)
        // Absorbs taps on the card so they don't reach the dismiss backdrop.
        .contentShape(Rectangle())
        .onTapGesture { }
    }

    /// The customer's typed tip, or nil to fall back to whatever `get_fair` had.
    var tipValue: Double? {

        guard let typed = Double(tip), typed > 0 else { return nil }

        return typed
    }

    /// What goes up as `driver_tip` — the customer's amount when they entered
    /// one, otherwise the booking's existing tip.
    var payableTip: String {

        if let tipValue {
            return String(format: "%.2f", tipValue)
        }

        return context.fare?.driverTip ?? "0"
    }

    func handleSubmit(rating: Int, comment: String, tip: String) {

        self.rating = rating
        self.comment = comment
        self.tip = tip

        // The booking fee alone keeps this above zero in normal operation; this
        // only catches a fare that came back malformed. Stripe refuses a zero
        // charge outright, so it must not get that far.
        guard ReceiptView.totalFareValue(for: context.fare, tipOverride: tipValue) > 0 else {
            errorMessage = "This trip's fare isn't available yet. Please try again shortly."
            return
        }

        // Android: `if (cardDetails == null) toast("No Payment Details...")` —
        // the receipt stays open and nothing is sent.
        guard paymentViewModel.cardDetails?.isUsable == true else {
            errorMessage = "No Payment Details. Please add a card first."
            return
        }

        errorMessage = nil
        isShowingPayment = true
    }
}
