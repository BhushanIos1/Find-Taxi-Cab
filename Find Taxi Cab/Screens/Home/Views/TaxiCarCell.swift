//
//  TaxiCarCell.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 09/03/26.
//

import SwiftUI

struct TaxiCarCell: View {
    
    let car: VehicleModel
    
    var body: some View {
        
        HStack(spacing: 10) {
            
            Image("estimatedTaxi")
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 56)
            
            HStack(spacing: 4) {
                Text("£")
                    .font(AppFont.font(.medium, size: 25))
                
                Text(car.price)
                    .font(AppFont.font(.medium, size: 16))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .allowsTightening(true)
            }
            .foregroundStyle(.black)
            
            Spacer()
            
            HStack(spacing: 4) {
                
                Image(systemName: "carseat.left.fill")
                
                Text("\(car.seater)")
            }
            .font(AppFont.font(.medium, size: 16))
            .foregroundStyle(.black)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "gauge.open.with.lines.needle.33percent")
                Text(String(format: "%.1f", car.distance))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .allowsTightening(true)
            }
            .font(AppFont.font(.medium, size: 16))
            .foregroundStyle(.black)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(.white)
        )
        .cardStyle()
    }
}
