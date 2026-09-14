//
//  ChatMessage.swift
//  Find Taxi Cab Driver
//
//  Created by Bhushan Kumar on 04/07/26.
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let time: String
    let isSender: Bool
    let isRead: Bool
}
