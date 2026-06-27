//
//  BookingPreview.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 08/03/26.
//

import SwiftUI

struct BookingPreview: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    let pickupAddress: String
    let destinationAddress: String
    
    let fromLat: Double
    let fromLong: Double
    let toLat: Double
    let toLong: Double
    
    @State private var selectedDisability: DisabilityOption? = nil
    @State private var passengers = 1
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 0) {
                
                headerView
                
                SpecialNeedsView(selectedDisability: $selectedDisability)
                    .padding(.top, 22)
                
                PassengerDropdown(passengers: $passengers)
                    .padding(.top, 6)
                
                getCabButton
                    .padding(.top, 30)
            }
            .padding(20)
        }
        .appNavigationBar(
            title: "Booking Preview",
            leading: .back
        ) {
            router.pop()
        }
    }
}

private extension BookingPreview {
    
    var headerView: some View {
        
        BookingPreviewHeader(
            pickupAddress: .constant(pickupAddress),
            destinationAddress: .constant(destinationAddress),
            selectedDate: .constant(.now),
            selectedType: .constant(.immediate),
            onAdvanceTap: {},
            showBookingType: false
        )
    }
}

private extension BookingPreview {
    
    var getCabButton: some View {
        
        Button {
            
            print("\(fromLat)")
            print("\(fromLong)")
            print("\(toLat)")
            print("\(toLong)")
            
            router.push(
                .getCabScreen(pickupAddress: pickupAddress,
                              destinationAddress: destinationAddress,
                              fromLat: fromLat,
                              fromLong: fromLong,
                              toLat: toLat,
                              toLong: toLong,
                              specialDisability: selectedDisability?.rawValue ?? "",
                              passengerCount: passengers)
            )
        } label: {
            Text("GET CAB")
                .primaryButtonStyle()
        }
    }
}
