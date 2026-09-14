//
//  ReceiptView.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 19/03/26.
//

import SwiftUI

struct ReceiptView: View {

    @Environment(\.colorScheme) var colorScheme

    /// Populated from `api/get_fair` — see `TrackingViewModel.getFareDetails()`,
    /// triggered by the driver app's `book_complete` push.
    let fare: FareBreakdown?

    var onSubmit: (_ rating: Int, _ comment: String, _ tip: String) -> Void = { _, _, _ in }
    var onDismiss: () -> Void = {}

    /// Last-resort booking fee, used only when `get_fair` doesn't return
    /// `percent_amt`.
    ///
    /// Android hardcodes £1.00 — `android:text="1.0"` in `fragment_invoice.xml`
    /// plus a literal `+ 1.00f` in `InvoiceFragment.calc_fair()` — and ignores
    /// the `percent_amt` and `total_amt` its own `getFairDetails()` reads off the
    /// response. That is safe only while the server's fee happens to be exactly
    /// £1; the moment it is a percentage, the displayed total stops matching the
    /// charge. `do_payment` sends no amount, so the server's figure always wins.
    static let fallbackBookingFee: Double = 1.00

    @State private var isTipSelected = false

    /// What the customer typed into the tip field. Was bound to `$comment` —
    /// the same binding as the comment box below — so typing a tip overwrote the
    /// comment and vice versa, and the amount never reached the total.
    @State private var tipText: String = ""

    @State private var rating: Int = 5
    @State private var comment: String = ""

    @FocusState private var isTipFocused: Bool
    @FocusState private var isCommentFocused: Bool

    var body: some View {

        VStack(alignment: .leading, spacing: 18) {
            
            Text("RECEIPT")
                .font(AppFont.font(.medium, size: 20))
            
            Divider()
            
            // FARE DETAILS
            fareRow(title: "Base Fare (£)", value: baseFareText)
            fareRow(title: "Booking Fee (£)", value: bookingFeeText)
            
            if let tip = tipAmount, tip > 0 {
                fareRow(title: "Driver Tip (£)", value: String(format: "%.2f", tip))
            }
            
            Divider()
            
            // TOTAL
            HStack {
                
                Spacer()
                
                Text("Total Fare (£)")
                
                Text(totalFareText)
            }
            .font(AppFont.font(.semiBold, size: 20))
            .foregroundColor(AppColors.grayDarkColor)
            
            // TIP CHECKBOX
            VStack(alignment: .leading) {

                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isTipSelected.toggle()

                            // Unticking clears it, so an amount the customer
                            // thought better of can't still be charged.
                            if !isTipSelected {
                                tipText = ""
                                isTipFocused = false
                            }
                        }
                    } label: {
                        Image(systemName: isTipSelected ? "checkmark.square.fill" : "square")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(colorScheme == .dark
                                             ? Color.white
                                             : Color.black)
                    }
                    
                    Text("Driver Tip (£)")
                        .font(AppFont.font(.regular, size: 16))
                }
                .padding(.bottom, 10)

                if isTipSelected {

                    VStack(spacing: 6) {

                        TextField("Tip Amount", text: $tipText)
                            .focused($isTipFocused)
                            .font(AppFont.font(.semiBold, size: 16))
                            .tint(AppColors.primaryYellow)
                            .keyboardType(.decimalPad)
                            .onChange(of: tipText) { newValue in

                                // The decimal pad still allows a second "." and
                                // a paste can bring anything at all; a malformed
                                // tip would silently become £0 at the total.
                                let cleaned = Self.sanitisedAmount(newValue)

                                if cleaned != newValue {
                                    tipText = cleaned
                                }
                            }

                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(isTipFocused ? AppColors.primaryYellow : .gray.opacity(0.5))
                            .animation(.easeInOut(duration: 0.2), value: isTipFocused)
                    }
                    .padding(.bottom, 10)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            
            // RATING
            VStack(alignment: .leading, spacing: 10) {
                
                Text("Rate Driver")
                    .font(AppFont.font(.semiBold, size: 18))
                    .foregroundColor(AppColors.grayDarkColor)
                
                HStack(spacing: 6) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(AppColors.primaryYellow)
                            .onTapGesture {
                                rating = index
                            }
                    }
                }
            }
            .padding(.bottom, 10)
            
            // COMMENT
            VStack(spacing: 6) {
                
                TextField("Comment", text: $comment)
                    .focused($isCommentFocused)
                    .font(AppFont.font(.semiBold, size: 16))
                    .tint(AppColors.primaryYellow)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(isCommentFocused ? AppColors.primaryYellow : .gray.opacity(0.5))
                    .animation(.easeInOut(duration: 0.2), value: isCommentFocused)
            }
            .padding(.bottom, 10)
            
            // BUTTONS
            HStack(spacing: 8) {

                Button {
                    onSubmit(rating, comment, enteredTip)
                } label: {
                    Text("SUBMIT")
                        .font(AppFont.font(.medium, size: 18))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.greenAppColor)
                        .foregroundColor(.white)
                }

                Button {
                    onDismiss()
                } label: {
                    Text("SKIP")
                        .font(AppFont.font(.medium, size: 18))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(colorScheme == .dark
                      ? Color(.systemGray6)
                      : Color(.white))
                .shadow(radius: 10)
        )
        .padding(20)
    }
}

private extension ReceiptView {

    var baseFare: Double? {
        fare?.baseFare.flatMap(Double.init)
    }

    /// The tip that actually applies: what the customer typed when the box is
    /// ticked, otherwise whatever `get_fair` already had on the booking.
    ///
    /// An override rather than an addition — `do_payment` takes `driver_tip` as a
    /// single value, so summing the two here would send a figure that no longer
    /// matches either.
    var tipAmount: Double? {

        if isTipSelected, let typed = Double(enteredTip), typed > 0 {
            return typed
        }

        return fare?.driverTip.flatMap(Double.init)
    }

    /// The tip as it will be sent, trimmed and validated.
    var enteredTip: String {
        isTipSelected ? tipText.trimmingCharacters(in: .whitespaces) : ""
    }

    var baseFareText: String {
        baseFare.map { String(format: "%.2f", $0) } ?? "—"
    }

    var bookingFeeText: String {
        String(format: "%.2f", ReceiptView.bookingFee(for: fare))
    }

    var totalFareText: String {
        ReceiptView.totalFare(for: fare, tipOverride: tipAmount)
    }
}

extension ReceiptView {

    /// The fee line. `percent_amt` is the server's own figure for it, so it is
    /// preferred over the hardcoded constant whenever `get_fair` sends it.
    static func bookingFee(for fare: FareBreakdown?) -> Double {

        if let percent = fare?.percentAmt.flatMap(Double.init), percent > 0 {
            return percent
        }

        return fallbackBookingFee
    }

    /// What the customer is told they will pay.
    ///
    /// `do_payment` posts no amount — only `booking_id`, `driver_tip` and the
    /// coupon `code` — so the server decides the charge and this string's only
    /// job is to predict it correctly. `total_amt` *is* the server's own total,
    /// which makes it the one figure guaranteed to agree; recomputing from parts
    /// is a guess at the server's arithmetic and is used only when `total_amt`
    /// is absent.
    ///
    /// The tip is added on top because `get_fair` returns it as a separate field
    /// and `do_payment` takes it as a separate parameter — i.e. the server adds
    /// it at charge time rather than folding it into `total_amt`.
    ///
    /// Static so the payment step quotes the exact number the receipt shows,
    /// instead of the two drifting apart with their own copies of the formula.
    static func totalFare(for fare: FareBreakdown?, tipOverride: Double? = nil) -> String {
        String(format: "%.2f", totalFareValue(for: fare, tipOverride: tipOverride))
    }

    /// Keeps a typed amount to digits and a single decimal point.
    static func sanitisedAmount(_ text: String) -> String {

        var seenSeparator = false

        let filtered = text.filter { character in

            if character.isNumber { return true }

            guard character == "." || character == "," else { return false }

            defer { seenSeparator = true }
            return !seenSeparator
        }

        return String(filtered.replacingOccurrences(of: ",", with: ".").prefix(8))
    }

    /// The same figure as a number — this is what gets charged, so the check,
    /// the displayed total and the amount sent to `do_payment` all read from here
    /// and cannot drift apart.
    ///
    /// The booking fee always applies, including on a trip whose `base_fair` is
    /// still 0 because the driver hasn't submitted one: a zero base fare gives a
    /// £1.00 total, not a £0.00 one. That is the rule confirmed by the client,
    /// and it is also what keeps Stripe from being handed a zero charge, which it
    /// refuses outright (`parameter_invalid_integer` — "This value must be
    /// greater than or equal to 1").
    static func totalFareValue(
        for fare: FareBreakdown?,
        tipOverride: Double? = nil
    ) -> Double {

        let tip = tipOverride ?? fare?.driverTip.flatMap(Double.init) ?? 0

        if let total = fare?.totalAmt.flatMap(Double.init), total > 0 {
            return total + tip
        }

        let base = fare?.baseFare.flatMap(Double.init) ?? 0

        return base + bookingFee(for: fare) + tip
    }

    /// Two decimal places, no currency symbol — the form `do_payment` is sent.
    static func payableAmount(for fare: FareBreakdown?, tipOverride: Double? = nil) -> String {
        String(format: "%.2f", totalFareValue(for: fare, tipOverride: tipOverride))
    }
}

/// What the receipt popup needs to run the full settle-up flow: which booking is
/// being paid, and the fare to show. Kept as one value so the id and the fare
/// can't drift apart.
struct ReceiptContext: Equatable {
    let bookingId: String
    let fare: FareBreakdown?
}

private extension ReceiptView {

    func fareRow(title: String, value: String) -> some View {
        
        HStack {
            Text(title)
            Spacer()
            Text(value)
            Spacer()
        }
        .font(AppFont.font(.semiBold, size: 16))
        .foregroundColor(AppColors.grayDarkColor)
    }
}

#Preview {
    ReceiptView(
        fare: FareBreakdown(
            baseFare: "15.50",
            percentAmt: "1.0",
            totalAmt: "16.50",
            driverTip: "0"
        )
    )
}
