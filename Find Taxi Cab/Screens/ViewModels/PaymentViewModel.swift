//
//  PaymentViewModel.swift
//  Find Taxi Cab
//
//  Created by Claude on 11/09/26.
//

import Foundation

enum PaymentState: Equatable {
    case paid(String)
    case failed(String)
}

@MainActor
final class PaymentViewModel: ObservableObject {

    /// The rider's saved card, fetched when the receipt opens. Android blocks the
    /// payment dialog entirely while this is nil ("No Payment Details...").
    @Published var cardDetails: CardDetails?

    @Published var isLoading = false
    @Published var paymentState: PaymentState?
    @Published var couponMessage: String?

    /// `POST /get_card_details` with `{custid}` — Android calls this from
    /// `InvoiceFragment.onViewCreated()`, before the rider can hit Submit.
    func loadCardDetails() {

        Task {

            do {

                let response: CardDetails = try await APIClient.shared.request(
                    CustomerAPI.getCardDetails,
                    responseType: CardDetails.self
                )

                cardDetails = response
                print("💳 CARD ON FILE: \(response.card ?? "none")")

            } catch {
                print("❌ CARD DETAILS ERROR:", error)
                cardDetails = nil
            }
        }
    }

    /// `POST /check_coupon` with `{code}`. Android only shows the returned message
    /// — it deliberately does not recalculate the displayed total, so this is
    /// informational rather than something that changes what gets charged.
    func applyCoupon(code: String) {

        guard !code.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        Task {

            do {

                let response: CommonResponse = try await APIClient.shared.request(
                    CustomerAPI.checkCoupon(code: code),
                    responseType: CommonResponse.self
                )

                couponMessage = response.message ?? "Coupon checked."

            } catch {
                print("❌ COUPON ERROR:", error)
                couponMessage = error.localizedDescription
            }
        }
    }

    /// `POST /do_payment` — the single call that both charges the trip and submits
    /// the rider's rating, comment and tip, exactly as Android does it. No amount
    /// is sent; the server derives the charge from `booking_id`.
    func pay(
        bookingId: String,
        card: String,
        month: String,
        year: String,
        cvc: String,
        couponCode: String,
        feedback: String,
        rating: Int,
        driverTip: String,
        amount: String
    ) {

        guard !isLoading else { return }

        isLoading = true

        Task {

            defer { isLoading = false }

            do {

                print("💳 CHARGING £\(amount) for booking \(bookingId)")

                let response: CommonResponse = try await APIClient.shared.request(
                    CustomerAPI.doPayment(
                        bookingId: bookingId,
                        card: card,
                        month: month,
                        year: year,
                        cvc: cvc,
                        code: couponCode,
                        feedback: feedback,
                        rating: "\(rating)",
                        driverTip: driverTip,
                        amount: amount
                    ),
                    responseType: CommonResponse.self
                )

                if response.result?.lowercased() == "success" {
                    paymentState = .paid(response.message ?? "Payment successful")
                } else {
                    paymentState = .failed(response.message ?? "Payment failed")
                }

            } catch {
                print("❌ PAYMENT ERROR:", error)
                paymentState = .failed(error.localizedDescription)
            }
        }
    }
}
