//
//  BookingScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI
import SwiftfulLoadingIndicators

/// Side menu ▸ Booking — Android's `BookingPage`.
///
/// One call, `client_last_book` with `{cust_id}`, rendered as a detail card.
/// CONTINUE hands the rider back to live tracking, but only for the three states
/// Android allows; anything else is a finished or abandoned trip and says so.
struct BookingScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject
    private var toastManager: ToastManager
    
    @StateObject
    private var viewModel = BookingViewModel()
    
    var body: some View {
        
        ZStack {
            
            if let booking = viewModel.lastBooking {
                bookingDetails(booking)
            } else if !viewModel.isLoading {
                emptyState
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
            title: "Booking Page",
            leading: .back) {
                router.pop()
            }
            .onAppear {
                viewModel.loadLastBooking()
            }
            .onChange(of: viewModel.bookingState) { state in
                
                guard let state else { return }
                
                switch state {
                    
                case .success(let message):
                    
                    toastManager.showToast(
                        type: .success,
                        title: "Success",
                        subtitle: message
                    )
                    
                    viewModel.errorMessage = nil
                    
                case .failure(let message):
                    
                    toastManager.showToast(
                        type: .error,
                        title: "Failed",
                        subtitle: message
                    )
                }
                
                DispatchQueue.main.async {
                    viewModel.bookingState = nil
                }
            }
            .overlay(GlobalToastView().environmentObject(toastManager))
    }
}

private extension BookingScreen {
    
    func bookingDetails(_ booking: ClientActiveBooking) -> some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(alignment: .leading) {
                
                Text("Booking Details")
                    .font(AppFont.font(.medium, size: 18))
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                
                VStack(alignment: .leading, spacing: 14) {
                    
                    detailRow("Booking Id :", booking.bookingId)
                    detailRow("Driver Mobile :", booking.driverMobile)
                    detailRow("Source Address :", booking.sourceAddress, isMultiline: true)
                    detailRow("Dest Address :", booking.destinationAddress, isMultiline: true)
                    detailRow("Booking Date :", booking.addedOn)
                    detailRow("Booking State :", booking.assignStatus?.capitalized)
                }
                .font(AppFont.font(.regular, size: 14))
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    colorScheme == .dark
                    ? Color(.systemGray6)
                    : Color(.white)
                )
                .shadow(
                    color: .black.opacity(0.08),
                    radius: 10,
                    x: 0,
                    y: 4
                )
                .padding(.horizontal, 20)
                
                Button {
                    continueBooking(booking)
                } label: {
                    Text("CONTINUE")
                        .primaryButtonStyle()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
    }
    
    @ViewBuilder
    func detailRow(
        _ title: String,
        _ value: String?,
        isMultiline: Bool = false
    ) -> some View {
        
        HStack(alignment: isMultiline ? .top : .center) {
            
            Text(title)
            
            Text(value?.isEmpty == false ? value! : "-")
        }
    }
    
    var emptyState: some View {
        
        NoDataView(
            icon: "car",
            message: viewModel.errorMessage ?? "You have no recent bookings."
        )
    }
    
    /// `BookingPage.continue_booking()` — only `accept`, `pickcustomer` and
    /// `onboard` can be resumed; everything else is over and done with.
    func continueBooking(_ booking: ClientActiveBooking) {
        
        guard booking.isResumable, let bookingId = booking.bookingId else {
            
            toastManager.showToast(
                type: .error,
                title: "Failed",
                subtitle: "You can't continue any booking!!!"
            )
            
            return
        }
        
        router.push(
            .tracking(
                TripContext(
                    bookingId: bookingId,
                    driverId: booking.driverId ?? "",
                    driverName: booking.driverName ?? "",
                    vehicleNo: booking.vehicleNo ?? "",
                    driverMobile: booking.driverMobile ?? "",
                    pickupAddress: booking.sourceAddress ?? "",
                    destinationAddress: booking.destinationAddress ?? "",
                    assignStatus: booking.assignStatus ?? ""
                )
            )
        )
    }
}

#Preview {
    BookingScreen()
}
