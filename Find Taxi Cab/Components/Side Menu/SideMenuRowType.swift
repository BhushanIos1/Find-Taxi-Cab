//
//  SideMenuRow.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI

enum SideMenuRowType: Int, CaseIterable {
    case home = 0
    case history
    case booking
    case emergency
    case setting
    case promotion
    case share
    case about
    case help
    case logout
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .history: return "History"
        case .booking: return "Booking Page"
        case .emergency: return "Emergency Call"
        case .setting: return "Settings"
        case .promotion: return "Promotions"
        case .share: return "Share"
        case .about: return "About"
        case .help: return "Help"
        case .logout: return "Logout"
        }
    }
    
    var iconName: String {
        
        switch self {
        case .home: return "menu1"
        case .history: return "menu2"
        case .booking: return "menu3"
        case .emergency: return "menu4"
        case .setting: return "menu5"
        case .promotion: return "menu6"
        case .share: return "menu7"
        case .about: return "menu8"
        case .help: return "menu9"
        case .logout: return "menu10"
        }
    }
}
