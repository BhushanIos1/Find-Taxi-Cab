//
//  BookingListCell.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI

struct BookingListCell: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let item: BookingItem
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 15) {
            
            HStack(alignment: .top) {
                
                Image(systemName: "car.fill")
                    .resizable()
                    .foregroundColor(.black)
                    .frame(width: 72, height: 32)
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text(item.dateTime)
                        .font(AppFont.font(.semiBold, size: 16))
                        .foregroundColor(AppColors.grayDarkColor)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Booking No   \(item.bookingNo)")
                        Text("Car Reg. No   \(item.carRegNo)")
                        
                        Text(item.addressLine)
                    }
                    .font(AppFont.font(.regular, size: 14))
                    
                    
                    Text(item.status.title)
                        .font(AppFont.font(.semiBold, size: 18))
                        .foregroundColor(item.status.color)
                }
                
                Spacer()
                
                Text(item.price)
                    .font(AppFont.font(.regular, size: 18))
                    .foregroundColor(AppColors.grayDarkColor)
            }
        }
        .padding(20)
        .background(
            colorScheme == .dark
            ? Color(.systemGray6)
            : Color(.white)
        )
        .shadow(
            color: .black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

#Preview {
    BookingListCell(item: BookingItem(
        dateTime: "15/02/2026   00:05:05",
        price: "£81.60",
        bookingNo: "943",
        carRegNo: "N44BYG",
        addressLine: "22 Cornmill Dr, Liversedge WF15, UK Sheffield, UK",
        status: .completed
    ))
}
