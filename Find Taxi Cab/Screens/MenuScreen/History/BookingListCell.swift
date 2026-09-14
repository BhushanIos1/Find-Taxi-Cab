//
//  BookingListCell.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI

struct BookingListCell: View {

    @Environment(\.colorScheme) var colorScheme

    let item: BookingItem

    var onPay: () -> Void = {}

    var body: some View {

        VStack(alignment: .leading, spacing: 15) {

            HStack(alignment: .top) {

                Image(systemName: "car.fill")
                    .resizable()
                    .foregroundColor(.black)
                    .frame(width: 72, height: 32)

                VStack(alignment: .leading, spacing: 20) {

                    Text(item.dateTime)
                        .font(AppFont.font(.semiBold, size: 16))
                        .foregroundColor(AppColors.grayDarkColor)

                    VStack(alignment: .leading, spacing: 14) {

                        Text("Booking No   \(item.bookingId ?? "—")")
                        Text("Car Reg. No   \(item.vehicleNo ?? "—")")

                        Text(item.sourceAddress ?? "—")
                        Text(item.destinationAddress ?? "—")

                        if let need = item.specialNeed, !need.isEmpty {
                            Text("Special Need   \(need)")
                        }

                        if let message = item.specialMessage, !message.isEmpty {
                            Text(message)
                        }
                    }
                    .font(AppFont.font(.regular, size: 14))

                    Text(item.statusTitle)
                        .font(AppFont.font(.semiBold, size: 18))
                        .foregroundColor(item.statusColor)
                }

                Spacer()

                Group {
                    // Android shows Pay only for a completed, still-unpaid trip;
                    // every other status shows the amount instead.
                    if item.canPay {

                        Button(action: onPay) {
                            Text("Pay")
                                .font(AppFont.font(.medium, size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: 84)
                                .frame(height: 50)
                                .background(AppColors.primaryYellow)
                                .cornerRadius(5)
                        }

                    } else {

                        Text(item.amountDisplay)
                            .font(AppFont.font(.regular, size: 18))
                            .foregroundColor(AppColors.grayDarkColor)
                    }
                }
                .frame(minWidth: 84, alignment: .trailing)
            }
        }
        .padding(20)
        .background(
            colorScheme == .dark
            ? Color(.systemGray6)
            : Color(.white)
        )
        .shadow(
            color: .black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

#Preview {
    BookingListCell(item: BookingItem(
        assignStatus: "complete",
        date: "15/02/2026",
        time: "00:05:05",
        bookingId: "943",
        vehicleNo: "N44BYG",
        sourceAddress: "22 Cornmill Dr, Liversedge WF15, UK",
        destinationAddress: "Sheffield, UK",
        paymentStatus: "0",
        totalAmount: "81.60",
        driverTip: "0",
        baseFare: "78.60"
    ))
}
