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

    var apiDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }

    var apiTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}

extension UIImage {

    func toBase64(compression: CGFloat = 0.7) -> String? {
        jpegData(compressionQuality: compression)?
            .base64EncodedString()
    }
}
