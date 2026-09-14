//
//  AndroidAlertView.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 10/03/26.
//

import SwiftUI

struct AndroidAlertView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let message: String
    let buttonTitle: String
    let action: () -> Void
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            Text(message)
                .foregroundStyle(colorScheme == .dark ? .white : Color.black)
                .font(AppFont.font(.regular, size: 16))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                action()
            } label: {
                Text(buttonTitle)
                    .font(AppFont.font(.medium, size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(colorScheme == .dark ? AppColors.greenAppColor : Color.red)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(colorScheme == .dark
                      ? Color(.systemGray6)
                      : Color(.white))
                .shadow(radius: 20)
        )
        .padding(30)
    }
}

#Preview {
    AndroidAlertView(message: "Sorry No Vehicle Available. Please Try Later", buttonTitle: "OK", action: {})
}
