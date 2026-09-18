//
//  ChatMessage.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 04/07/26.
//

import SwiftUI

struct ChatMessage: Identifiable, Equatable {

    /// Server row id. Nil only while a just-typed message is still in flight —
    /// `after_id` paging needs the real one, so a local UUID can't stand in.
    let serverId: Int?

    private let localId = UUID()

    let text: String
    let time: String
    let isSender: Bool
    let isRead: Bool

    /// Sent but not yet confirmed by the server. Rendered dimmed so the customer
    /// can see it hasn't landed.
    let isPending: Bool

    var id: String {
        serverId.map(String.init) ?? localId.uuidString
    }

    init(
        serverId: Int? = nil,
        text: String,
        time: String,
        isSender: Bool,
        isRead: Bool,
        isPending: Bool = false
    ) {
        self.serverId = serverId
        self.text = text
        self.time = time
        self.isSender = isSender
        self.isRead = isRead
        self.isPending = isPending
    }
}

extension ChatMessage {

    /// `sender_type` tells us who wrote it; "mine" depends on which app is asking.
    init(dto: ChatMessageDTO, mySenderType: String) {

        self.init(
            serverId: dto.id,
            text: dto.text,
            time: dto.displayTime,
            isSender: dto.senderType == mySenderType,
            isRead: dto.isRead
        )
    }
}
