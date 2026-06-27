//
//  ToastType.swift
//  Find Taxi Cab Driver
//
//  Created by Bhushan Kumar on 08/04/26.
//

import SwiftUI

enum ToastType: String, Hashable, CaseIterable {
    
    case info, success, error, warning
    
    var backgroundColor: Color {
        switch self {
        case .info: Color.blue.opacity(0.1)
        case .success: Color.green.opacity(0.1)
        case .error: Color.red.opacity(0.1)
        case .warning: Color.orange.opacity(0.1)
        }
    }
    var titleColor: Color {
        switch self {
        case .info: .blue
        case .success: .green
        case .error: .red
        case .warning: .orange
        }
    }
    
    var icon: String {
        switch self {
        case .info: "info.circle"
        case .success: "checkmark.circle"
        case .error: "xmark.circle"
        case .warning: "exclamationmark.triangle"
        }
    }
}
