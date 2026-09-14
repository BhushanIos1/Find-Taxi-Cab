//
//  NotificationStatus.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 24/08/26.
//

enum NotificationStatus: String {

    // Customer
    case bookAccept = "book_accept"
    case bookPickCustomer = "book_pickcustomer"
    case bookOnboard = "book_onboard"
    case bookComplete = "book_complete"
    case bookCancelled = "book_cancelled"
    case noDriver = "nodriver"
    
    case unknown
}

extension NotificationStatus {
    
    init(value: String?) {
        self = NotificationStatus(rawValue: value ?? "") ?? .unknown
    }
}
