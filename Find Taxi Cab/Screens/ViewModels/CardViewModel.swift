//
//  CardViewModel.swift
//  Find Taxi Cab
//
//  Created by Claude on 12/09/26.
//

import SwiftUI

enum CardUpdateState: Equatable {
    case success(String)
    case failure(String)
}

/// Settings ▸ Edit Credit Card, the counterpart of Android's `AddCardActivity`.
///
/// Android only ever *writes* here — its form opens blank every time. This one
/// also reads `get_card_details` first so the customer can see what is on file
/// instead of having to retype a number they cannot check.
@MainActor
final class CardViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var cardDetails: CardDetails?
    @Published var updateState: CardUpdateState?

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
                // No card yet is the normal first-run state, not an error worth
                // interrupting the customer for — the form simply stays blank.
                print("❌ CARD DETAILS ERROR:", error)
                cardDetails = nil
            }
        }
    }

    func updateCard(
        cardNumber: String,
        cardHolderName: String,
        month: String,
        year: String,
        cvv: String
    ) {

        guard !isLoading else { return }

        isLoading = true

        Task {

            defer { isLoading = false }

            do {

                let response: CommonResponse = try await APIClient.shared.request(
                    CustomerAPI.editCardDetails(
                        cardNumber: cardNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                        cardHolderName: cardHolderName.trimmingCharacters(in: .whitespacesAndNewlines),
                        cardMonth: month,
                        cardYear: year,
                        cvv: cvv.trimmingCharacters(in: .whitespacesAndNewlines)
                    ),
                    responseType: CommonResponse.self
                )

                if response.result?.lowercased() == "success" {

                    let message = response.message ?? "Card Updated"
                    print("✅ CARD UPDATED:", message)

                    // Keep the local copy in step so the payment popup prefills
                    // the new card without a round trip.
                    cardDetails = CardDetails(
                        card: cardNumber,
                        month: month,
                        year: year,
                        cardHolderName: cardHolderName
                    )

                    updateState = .success(message)

                } else {

                    let message = response.message ?? "Failed To Update Card"
                    print("❌ CARD UPDATE FAILED:", message)
                    updateState = .failure(message)
                }

            } catch {

                print("❌ UPDATE CARD ERROR:", error)
                updateState = .failure(error.localizedDescription)
            }
        }
    }
}
