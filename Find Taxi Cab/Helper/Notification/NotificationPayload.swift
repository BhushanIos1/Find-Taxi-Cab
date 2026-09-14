//
//  NotificationPayload.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 24/08/26.
//

struct NotificationPayload {
    
    let status: NotificationStatus
    let bookingId: String?
    let title: String?
    let message: String?
    
    init(userInfo: [AnyHashable: Any]) {
        
        let statusString =
            userInfo["status"] as? String ??
            userInfo["tag"] as? String
        
        self.status = NotificationStatus(value: statusString)
        
        self.bookingId =
            userInfo["booking_id"] as? String ??
            userInfo["book_id"] as? String
        
        self.title =
            userInfo["title"] as? String ??
            (userInfo["aps"] as? [String: Any])?["alert"] as? String
        
        self.message =
            userInfo["message"] as? String ??
            userInfo["body"] as? String
    }
}

