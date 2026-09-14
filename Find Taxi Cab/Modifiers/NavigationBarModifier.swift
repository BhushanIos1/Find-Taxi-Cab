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
            
            // Without this the VStack sizes itself to its children and then
            // centres in the parent, so any screen whose content is short — an
            // empty list, a two-line message — drags the navigation bar down to
            // the middle of the display. Claiming the remaining height keeps the
            // bar pinned under the status bar regardless of what's below it.
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(true)
    }
}
