//
//  View.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 26/02/26.
//

import SwiftUI

extension View {
    
    func appNavigationBar(
        title: String,
        leading: NavBarLeadingType,
        onMenuTap: (() -> Void)? = nil
    ) -> some View {
        
        modifier(
            AppNavigationBar(
                title: title,
                leading: leading,
                onMenuTap: onMenuTap
            )
        )
    }
    
    /// Presents the receipt as a centred popover over a dimmed backdrop, dismissed
    /// by tapping outside it. Android shows this as a `DialogFragment`, which has
    /// the same feel — a sheet slides up from the bottom and reads as a different
    /// kind of moment.
    ///
    /// Driven by the fare itself rather than a separate boolean: there is no state
    /// where the receipt should be up without a fare to show, so binding the two
    /// together removes the chance of them disagreeing.
    func receiptPopup(
        context: Binding<ReceiptContext?>,
        onFinished: @escaping () -> Void = {}
    ) -> some View {

        self.overlay {

            if let value = context.wrappedValue {

                // `ReceiptFlowView` owns its own backdrops — it needs two, so the
                // card dialog can dim the receipt behind it independently.
                ReceiptFlowView(context: value) {
                    context.wrappedValue = nil
                    onFinished()
                }
                .transition(.opacity)
                .zIndex(999)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: context.wrappedValue)
    }

    func cardStyle() -> some View {
        modifier(CardModifier())
    }
    
    func primaryButtonStyle(
        height: CGFloat = 52,
        background: Color = AppColors.primaryYellow,
        textColor: Color = .white
    ) -> some View {
        
        modifier(
            PrimaryButtonModifier(
                height: height,
                background: background,
                textColor: textColor
            )
        )
    }
}

extension Bundle {
    
    var appName: String {
        object(
            forInfoDictionaryKey: "CFBundleDisplayName"
        ) as? String
        ??
        object(
            forInfoDictionaryKey: "CFBundleName"
        ) as? String
        ??
        ""
    }
}

extension String {
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    static var currentDate: String {
        dateFormatter.string(from: Date())
    }
    
    static var currentTime: String {
        timeFormatter.string(from: Date())
    }
}

extension Date {

    /// Fixed-format output for the API, never for display.
    ///
    /// The locale is pinned to `en_US_POSIX` deliberately. Without it a
    /// `DateFormatter` follows the device: on a phone with 24-Hour Time switched
    /// off, `HH` still renders as "2:32 PM", and under a non-Gregorian calendar
    /// `yyyy` is not the Gregorian year at all. Either one produces a booking the
    /// backend cannot store.
    private static let apiFormatter: DateFormatter = {

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()

    private func apiString(format: String) -> String {

        let formatter = Self.apiFormatter
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    var apiDate: String {
        apiString(format: "yyyy-MM-dd")
    }

    var apiTime: String {
        apiString(format: "HH:mm")
    }
}

extension UIImage {

    func toBase64(compression: CGFloat = 0.7) -> String? {
        jpegData(compressionQuality: compression)?
            .base64EncodedString()
    }
}
