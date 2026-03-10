//
//  BookingPreviewHeader.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 08/03/26.
//

import SwiftUI

struct BookingPreviewHeader: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var pickupAddress: String
    @Binding var destinationAddress: String
    @Binding var selectedDate: Date
    @Binding var selectedType: BookingType
    
    let onAdvanceTap: () -> Void
    
    var showBookingType: Bool = true
    
    var body: some View {
        
        VStack(spacing: 18) {
            
            addressRow(
                icon: "dot.circle",
                color: .green,
                text: pickupAddress
            )
            
            addressRow(
                icon: "dot.circle",
                color: .red,
                text: destinationAddress
            )
            
            Divider()
            
            dateTimeRow
            
            if showBookingType {
                bookingTypeSelector
            }
        }
        .padding(20)
        .background(backgroundColor)
        .cardStyle()
        .shadow(
            color: .black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

extension BookingPreviewHeader {
    
    // MARK: Background
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : .white
    }
    
    // MARK: Address Row
    
    private func addressRow(
        icon: String,
        color: Color,
        text: String
    ) -> some View {
        
        HStack(alignment: .top, spacing: 10) {
            
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 16)
            
            Text(text)
                .font(AppFont.font(.regular, size: 14))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: Date Time Row
    
    private var dateTimeRow: some View {
        
        HStack(spacing: 15) {
            
            dateItem(
                icon: "calendar",
                text: selectedDate.formatted(date: .abbreviated, time: .omitted)
            )
            
            dateItem(
                icon: "clock.fill",
                text: selectedDate.formatted(date: .omitted, time: .shortened)
            )
            
            Spacer(minLength: 0)
        }
    }
    
    private func dateItem(
        icon: String,
        text: String
    ) -> some View {
        
        HStack(spacing: 5) {
            
            Image(systemName: icon)
                .foregroundStyle(AppColors.primaryYellow)
            
            Text(text)
                .font(AppFont.font(.regular, size: 14))
        }
    }
    
    // MARK: Booking Type Selector
    
    private var bookingTypeSelector: some View {
        
        HStack(spacing: 20) {
            
            radioItem(
                title: "Immediate Booking",
                type: .immediate
            )
            
            radioItem(
                title: "Advance Booking",
                type: .advance
            )
            
            Spacer(minLength: 0)
        }
        .padding(.top, 5)
    }
    
    // MARK: Radio Item
    
    private func radioItem(
        title: String,
        type: BookingType
    ) -> some View {
        
        Button {
            selectedType = type
            
            if type == .advance {
                onAdvanceTap()
            }
            
        } label: {
            
            HStack(spacing: 8) {
                
                ZStack {
                    
                    Circle()
                        .stroke(Color.red, lineWidth: 2)
                        .frame(width: 18, height: 18)
                    
                    if selectedType == type {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                    }
                }
                
                Text(title)
                    .font(AppFont.font(.regular, size: 14))
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    
    BookingPreviewHeader(
        pickupAddress: .constant("Pickup Address Pickup Address Pickup Address Pickup Address"),
        destinationAddress: .constant("Destination Address Pickup Address Pickup Address"),
        selectedDate: .constant(Date()),
        selectedType: .constant(.immediate),
        onAdvanceTap: {}, showBookingType: true
    )
    //PassengerDropdown(passengers: .constant(1))
}

enum BookingType {
    case immediate
    case advance
}

struct PassengerDropdown: View {
    
    @Binding var passengers: Int
    
    let options = [1,2,3,4,5,6,7,8,9,10]
    
    var body: some View {
        
        Menu {
            
            ForEach(options, id: \.self) { number in
                
                Button {
                    passengers = number
                } label: {
                    
                    HStack {
                        Text("\(number) Passenger\(number > 1 ? "s" : "")")
                            .font(AppFont.font(.regular, size: 14))
                        
                        if passengers == number {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            
        } label: {
            
            HStack {
                
                Text("\(passengers) Passenger\(passengers > 1 ? "s" : "")")
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
            }
            .font(AppFont.font(.regular, size: 14))
            .tint(.primary)
            .padding(.vertical, 6)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.6)),
                alignment: .bottom
            )
        }
    }
}
