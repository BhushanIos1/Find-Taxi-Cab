//
//  Modifiers.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 26/02/26.
//

import SwiftUI

struct AppNavigationBar: ViewModifier {
    
    let title: String
    let leading: NavBarLeadingType
    var onMenuTap: (() -> Void)?
    
    func body(content: Content) -> some View {
        
        VStack(spacing: 0) {
            
            CustomNavigationBar(
                title: title,
                leadingType: leading,
                onMenuTap: onMenuTap
            )
            
            content
        }
        .navigationBarBackButtonHidden(true)
    }
}
