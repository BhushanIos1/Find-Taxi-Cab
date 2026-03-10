//
//  RideLocationCard.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 08/03/26.
//

import SwiftUI

struct RideLocationCard: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var pickupAddress: String
    @Binding var destinationAddress: String
    
    var pickupTap: () -> Void
    var destinationTap: () -> Void
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack(alignment: .top, spacing: 10) {
                
                HStack {
                    Image("pickup_pin")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text(
                        pickupAddress.isEmpty
                        ? "Enter Pickup Address"
                        : pickupAddress
                    )
                    .font(AppFont.font(.regular, size: 14))
                    .foregroundColor(
                        pickupAddress.isEmpty
                        ? .gray
                        : .primary
                    )
                }
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.green)
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                pickupTap()
            }
            
            Divider()
                .padding(.horizontal, 12)
            
            HStack(spacing: 10) {
                
                Image("destination_pin")
                    .resizable()
                    .frame(width: 30, height: 30)
                
                Text(
                    destinationAddress.isEmpty
                    ? "Destination Address"
                    : destinationAddress
                )
                .font(AppFont.font(.regular, size: 14))
                .foregroundColor(
                    destinationAddress.isEmpty
                    ? .gray
                    : .primary
                )
                Spacer()
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                destinationTap()
            }
        }
        .background(colorScheme == .dark
                    ? Color(.systemGray6)
                    : Color(.white))
        .shadow(
            color: .black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

#Preview {
    RideLocationCard(
        pickupAddress: .constant(""),
        destinationAddress: .constant(""),
        pickupTap: {
            
        },
        destinationTap: {
            
        }
    )
}

struct RideLocation {
    var pickupAddress: String = ""
    var destinationAddress: String = ""
}

enum SearchType {
    case pickup
    case destination
}
