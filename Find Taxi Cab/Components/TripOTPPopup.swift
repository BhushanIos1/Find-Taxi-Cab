//
//  TripOTPPopup.swift
//  Find Taxi Cab
//
//  Created by Claude on 30/09/26.
//

import SwiftUI

/// Shown once, the moment the driver taps ON BOARD and the server generates a
/// trip-start code — Android's own SMS is still what the driver actually reads
/// off; this is just the in-app copy of the same code, matched on-screen rather
/// than left to whatever the Messages app happened to do with it.
struct TripOTPPopup: View {

    @Environment(\.colorScheme) private var colorScheme

    let otp: String
    var onClose: () -> Void

    var body: some View {

        ZStack {

            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { onClose() }

            card
                .padding(.horizontal, 32)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }
}

private extension TripOTPPopup {

    var card: some View {

        VStack(spacing: 22) {

            closeRow

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 38))
                .foregroundStyle(AppColors.primaryYellow)

            Text("Trip OTP")
                .font(AppFont.font(.semiBold, size: 22))
                .foregroundStyle(colorScheme == .dark ? .white : .black)

            Text("Share this code with your driver to start the trip.")
                .font(AppFont.font(.regular, size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)

            otpDigits

            Button(action: onClose) {
                Text("OK")
                    .font(AppFont.font(.medium, size: 17))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppColors.primaryYellow)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.top, 12)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
        )
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 8)
    }

    var closeRow: some View {

        HStack {

            Spacer()

            Button(action: onClose) {

                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(colorScheme == .dark ? .white : AppColors.grayDarkColor)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color(.systemGray5) : AppColors.uberLightGray)
                    )
            }
        }
    }

    /// One boxed digit per character — the same shape the driver's own OTP entry
    /// uses, so the code reads as the same object on both ends of the trip.
    var otpDigits: some View {

        HStack(spacing: 10) {

            ForEach(Array(otp.enumerated()), id: \.offset) { _, digit in

                Text(String(digit))
                    .font(AppFont.font(.bold, size: 28))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .frame(width: 48, height: 58)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppColors.primaryYellow, lineWidth: 1.5)
                    )
            }
        }
    }
}

#Preview {
    TripOTPPopup(otp: "4821") { }
}
