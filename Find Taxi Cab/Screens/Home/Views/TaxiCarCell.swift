//
//  TaxiCarCell.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 09/03/26.
//

import SwiftUI

struct TaxiCarCell: View {
    
    var body: some View {
        
        HStack(spacing: 20) {
            
            // Car Image
            Image("car_taxi") // your asset image
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 50)
            
            Spacer()
            
            // Price
            HStack(spacing: 4) {
                Text("£")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("20.70")
                    .font(.headline)
            }
            
            Spacer()
            
            // Seat Count
            HStack(spacing: 6) {
                Image(systemName: "seat.side.rear.fill")
                    .font(.system(size: 16))
                
                Text("4")
                    .font(.headline)
            }
            
            Spacer()
            
            // Speed / Metric
            HStack(spacing: 6) {
                Image(systemName: "gauge.with.dots.needle.33percent")
                    .font(.system(size: 16))
                
                Text("6")
                    .font(.headline)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .cardStyle()
        .padding(.horizontal)
    }
}

#Preview {
    TaxiCarCell()
}
