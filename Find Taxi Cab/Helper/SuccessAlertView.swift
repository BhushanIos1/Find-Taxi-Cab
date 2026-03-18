//
//  SuccessAlertView.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 18/03/26.
//

import SwiftUI

struct SuccessAlertView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let message: String
    
    var body: some View {
        
        VStack(spacing: 15) {
            
            Image("success")
                .resizable()
                .frame(width: 90, height: 90)
            
            Text(message)
                .font(AppFont.font(.medium, size: 35))
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.greenAppColor)
                .lineLimit(1)
                .truncationMode(.tail)
                .minimumScaleFactor(0.7)
                .padding(.horizontal)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(colorScheme == .dark
                      ? Color(.systemGray6)
                      : Color(.white))
                .shadow(radius: 20)
        )
        .padding(10)
    }
}

#Preview {
    SuccessAlertView(message: "Booking Accepted")
}
