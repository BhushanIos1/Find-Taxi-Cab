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
