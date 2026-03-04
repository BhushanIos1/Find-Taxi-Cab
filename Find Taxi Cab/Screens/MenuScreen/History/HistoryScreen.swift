//
//  HostroyScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI

struct HistoryScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    let bookings: [BookingItem] = [
        BookingItem(
            dateTime: "15/02/2026   00:05:05",
            price: "£81.60",
            bookingNo: "943",
            carRegNo: "N44BYG",
            addressLine: "22 Cornmill Dr, Liversedge WF15, UK, Sheffield, UK",
            status: .completed
        ),
        BookingItem(
            dateTime: "15/02/2026   00:05:05",
            price: "£81.60",
            bookingNo: "943",
            carRegNo: "N44BYG",
            addressLine: "22 Cornmill Dr, Liversedge WF15, UK, Sheffield, UK",
            status: .cancelled
        ),
        BookingItem(
            dateTime: "15/02/2026   00:05:05",
            price: "£81.60",
            bookingNo: "943",
            carRegNo: "N44BYG",
            addressLine: "22 Cornmill Dr, Liversedge WF15, UK, Sheffield, UK",
            status: .pending
        ),
        BookingItem(
            dateTime: "15/02/2026   00:05:05",
            price: "£81.60",
            bookingNo: "943",
            carRegNo: "N44BYG",
            addressLine: "22 Cornmill Dr, Liversedge WF15, UK, Sheffield, UK",
            status: .completed
        )
    ]
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                
                LazyVStack(spacing: 20) {
                    ForEach(bookings) { booking in
                        BookingListCell(item: booking)
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .appNavigationBar(
            title: "History",
            leading: .back) {
                router.pop()
            }
    }
}

#Preview {
    HistoryScreen()
}
