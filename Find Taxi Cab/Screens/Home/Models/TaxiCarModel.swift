//
//  TaxiCar.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 09/03/26.
//

import SwiftUI

struct TaxiCarModel: Identifiable {
    let id = UUID()
    let image: String
    let price: Double
    let seats: Int
    let metric: Int
}
