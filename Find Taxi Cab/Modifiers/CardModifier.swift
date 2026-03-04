//
//  CardModifier.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 26/02/26.
//

import SwiftUI

struct CardModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(AppColors.yellowBorder, lineWidth: 1)
            )
            .shadow(
                color: AppColors.yellowBorder.opacity(0.08),
                radius: 4,
                x: 0,
                y: 2
            )
            .contentShape(RoundedRectangle(cornerRadius: 4))
    }
}
