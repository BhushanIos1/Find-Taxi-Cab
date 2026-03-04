//
//  PrimaryButtonModifier.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 28/02/26.
//

import SwiftUI

struct PrimaryButtonModifier: ViewModifier {
    
    var height: CGFloat = 52
    var background: Color = AppColors.primaryYellow
    var textColor: Color = .white
    
    func body(content: Content) -> some View {
        
        content
            .font(AppFont.font(.medium, size: 18))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(background)
    }
}
