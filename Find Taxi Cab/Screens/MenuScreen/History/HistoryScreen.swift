//
//  HostroyScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct HistoryScreen: View {

    @EnvironmentObject
    private var router: AppRouter

    @StateObject
    private var viewModel = HistoryViewModel()

    /// The booking whose Pay button was tapped — drives the receipt popover, the
    /// same way Android's Pay button opens `InvoiceFragment` with `base_fair` /
    /// `driver_tip` / `booking_id` in its bundle.
    @State private var receiptContext: ReceiptContext?

    var body: some View {

        ZStack {

            if viewModel.bookings.isEmpty, !viewModel.isLoading {

                emptyState

            } else {

                ScrollView {

                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.bookings) { booking in
                            BookingListCell(item: booking) {
                                receiptContext = ReceiptContext(
                                    bookingId: booking.bookingId ?? "",
                                    fare: FareBreakdown(
                                        baseFare: booking.baseFare,
                                        percentAmt: nil,
                                        totalAmt: booking.totalAmount,
                                        driverTip: booking.driverTip
                                    )
                                )
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }

            if viewModel.isLoading {

                LoadingIndicator(
                    animation: .circleTrim,
                    color: AppColors.primaryYellow,
                    size: .medium,
                    speed: .normal
                )
            }
        }
        .appNavigationBar(
            title: "History",
            leading: .back) {
                router.pop()
            }
        .onAppear {
            viewModel.loadHistory()
        }
        .receiptPopup(context: $receiptContext) {
            viewModel.loadHistory()
        }
    }
}

private extension HistoryScreen {

    var emptyState: some View {

        NoDataView(
            icon: "clock.arrow.circlepath",
            message: viewModel.errorMessage ?? "You haven't taken any trips yet."
        )
    }
}

#Preview {
    HistoryScreen()
}
