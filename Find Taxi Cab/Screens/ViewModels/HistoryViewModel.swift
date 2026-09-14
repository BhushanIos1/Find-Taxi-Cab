//
//  HistoryViewModel.swift
//  Find Taxi Cab
//
//  Created by Claude on 09/09/26.
//

import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {

    @Published var bookings: [BookingItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// `POST /get_book_list` with `{client_id}` — the same call Android makes in
    /// `HistoryActivity.loadBookingHistory()`.
    func loadHistory() {

        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {

            defer { isLoading = false }

            do {

                let response: BookingHistoryResponse = try await APIClient.shared.request(
                    CustomerAPI.bookingList,
                    responseType: BookingHistoryResponse.self
                )

                // Android displays this list with `setReverseLayout(true)`, so the
                // most recent booking reads first. Reversing here keeps that
                // ordering without the view needing to know about it.
                bookings = (response.bookingData ?? []).reversed()

                print("📋 BOOKING HISTORY: \(bookings.count) booking(s)")

            } catch {

                print("❌ BOOKING HISTORY ERROR:", error)
                errorMessage = error.localizedDescription
                bookings = []
            }
        }
    }
}
