//
//  TaxiCarCell.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 09/03/26.
//

import SwiftUI

struct TaxiCarCell: View {
    
    let car: TaxiCarModel
    
    var body: some View {
        
        HStack(spacing: 10) {
            
            Image(car.image)
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 56)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("£")
                    .font(AppFont.font(.medium, size: 25))
                
                Text(car.price, format: .number.precision(.fractionLength(2)))
                    .font(AppFont.font(.medium, size: 16))
                    .lineLimit(1)
            }
            .foregroundStyle(.black)
            
            Spacer()
            
            HStack(spacing: 4) {
                
                Image(systemName: "carseat.left.fill")
                
                Text("\(car.seats)")
            }
            .font(AppFont.font(.medium, size: 16))
            .foregroundStyle(.black)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "gauge.open.with.lines.needle.33percent")
                Text("\(car.metric)")
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

#Preview {
    TaxiCarCell(car:
                    TaxiCarModel(image: "taxi1", price: 20.75, seats: 4, metric: 2))
}
