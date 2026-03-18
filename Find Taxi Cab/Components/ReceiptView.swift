//
//  ReceiptView.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 19/03/26.
//

import SwiftUI

struct ReceiptView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isTipSelected = false
    @State private var rating: Int = 5
    @State private var comment: String = ""
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 18) {
            
            Text("RECEIPT")
                .font(AppFont.font(.medium, size: 20))
            
            Divider()
            
            // FARE DETAILS
            fareRow(title: "Base Fare (£)", value: "15.50")
            fareRow(title: "Booking Fee (£)", value: "1.0")
            
            Divider()
            
            // TOTAL
            HStack {
                
                Spacer()
                
                Text("Total Fare (£)")
                
                Text("16.50")
            }
            .font(AppFont.font(.semiBold, size: 20))
            .foregroundColor(AppColors.grayDarkColor)
            
            // TIP CHECKBOX
            HStack {
                Button {
                    isTipSelected.toggle()
                } label: {
                    Image(systemName: isTipSelected ? "checkmark.square.fill" : "square")
                        .foregroundColor(colorScheme == .dark
                                         ? Color.white
                                         : Color.black)
                        .frame(width: 26, height: 26)
                }
                
                Text("Drive Tip (£)")
                    .font(AppFont.font(.regular, size: 20))
            }
            .padding(.bottom, 10)
            
            // RATING
            VStack(alignment: .leading, spacing: 10) {
                
                Text("Rate Driver")
                    .font(AppFont.font(.semiBold, size: 20))
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
            VStack(alignment: .leading, spacing: 8) {
                
                Text("Comment")
                    .font(AppFont.font(.semiBold, size: 20))
                    .foregroundColor(AppColors.grayDarkColor)
                
                TextField("Write here...", text: $comment)
                    .textFieldStyle(.plain)
                
                Divider()
            }
            .padding(.bottom, 10)
            
            // BUTTONS
            HStack(spacing: 8) {
                
                Button {
                    // submit action
                } label: {
                    Text("SUBMIT")
                        .font(AppFont.font(.medium, size: 18))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.greenAppColor)
                        .foregroundColor(.white)
                }
                
                Button {
                    // cancel action
                } label: {
                    Text("CANCEL")
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
    ReceiptView()
}
