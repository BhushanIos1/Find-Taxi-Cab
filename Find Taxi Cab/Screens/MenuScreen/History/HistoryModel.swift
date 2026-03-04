//
//  HistoryModel.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI

struct BookingItem: Identifiable {
    
    let id = UUID()
    let dateTime: String
    let price: String
    let bookingNo: String
    let carRegNo: String
    let addressLine: String
    let status: BookingStatus
}

enum BookingStatus {
    case completed
    case cancelled
    case pending
    
    var title: String {
        switch self {
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .pending: return "Pending"
        }
    }
    
    var color: Color {
        switch self {
        case .completed: return Color(uiColor: .systemGreen)
        case .cancelled: return Color(uiColor: .systemRed)
        case .pending: return Color(uiColor: .systemOrange)
        }
    }
}
