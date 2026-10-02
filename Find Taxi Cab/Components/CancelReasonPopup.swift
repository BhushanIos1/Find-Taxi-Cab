//
//  CancelReasonPopup.swift
//  Find Taxi Cab
//
//  Created by Claude on 01/10/26.
//

import SwiftUI

/// The reason-for-cancellation step — replaces what used to be a plain "Cancel
/// Trip? Yes/No" confirm with no text entry at all. Typing a reason and
/// submitting *is* the confirmation here, the same shape as the driver app's
/// own cancel popup, so there's no separate "are you sure" dialog on top of it.
struct CancelReasonPopup: View {

    @Environment(\.colorScheme) private var colorScheme

    var isSubmitting: Bool = false

    /// `/cancel_book_client`'s own failure text — "Onboard booking cannot be
    /// cancelled" / "Book Status Not Changed" — shown inline rather than only
    /// as a toast, with the popup staying open so SUBMIT itself is the retry.
    var errorMessage: String? = nil

    var onSubmit: (_ reason: String) -> Void
    var onDismiss: () -> Void

    @State private var reason = ""
    @State private var showEmptyWarning = false

    @FocusState private var isFocused: Bool

    var body: some View {

        ZStack {

            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    // A request in flight shouldn't be abandoned by a stray tap
                    // outside the card — there'd be nothing left to retry with.
                    guard !isSubmitting else { return }
                    onDismiss()
                }

            card
                .padding(.horizontal, 24)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }
}

private extension CancelReasonPopup {

    var card: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Reason For Cancellation")
                .font(AppFont.font(.semiBold, size: 20))
                .foregroundStyle(colorScheme == .dark ? .white : .black)

            VStack(alignment: .leading, spacing: 6) {

                VStack(spacing: 4) {

                    TextField("Type here...", text: $reason)
                        .focused($isFocused)
                        .font(AppFont.font(.regular, size: 16))
                        .tint(AppColors.primaryYellow)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .onChange(of: reason) { _ in
                            showEmptyWarning = false
                        }

                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(
                            showEmptyWarning
                            ? .red
                            : (isFocused ? AppColors.primaryYellow : .gray.opacity(0.45))
                        )
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                }

                if showEmptyWarning {

                    Text("Please enter a reason for cancellation.")
                        .font(AppFont.font(.regular, size: 13))
                        .foregroundColor(.red)
                        .transition(.opacity)
                }

                if let errorMessage {

                    Text(errorMessage)
                        .font(AppFont.font(.regular, size: 13))
                        .foregroundColor(.red)
                        .transition(.opacity)
                }
            }

            HStack(spacing: 12) {

                Button {
                    onDismiss()
                } label: {
                    Text("Close")
                        .font(AppFont.font(.medium, size: 16))
                        .foregroundColor(colorScheme == .dark ? .white : AppColors.grayDarkColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            colorScheme == .dark ? Color(.systemGray5) : AppColors.uberLightGray
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(isSubmitting)

                Button {
                    submit()
                } label: {
                    Text(isSubmitting ? "Cancelling…" : "Submit")
                        .font(AppFont.font(.medium, size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(isSubmitting)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
        )
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 8)
        .animation(.easeInOut(duration: 0.2), value: showEmptyWarning)
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
    }

    func submit() {

        guard !isSubmitting else { return }

        let trimmed = reason.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            withAnimation {
                showEmptyWarning = true
            }
            return
        }

        onSubmit(trimmed)
    }
}

#Preview {
    CancelReasonPopup(onSubmit: { _ in }, onDismiss: { })
}
