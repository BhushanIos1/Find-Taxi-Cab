//
//  ChatModels.swift
//  Find Taxi Cab
//
//  Created by Claude on 16/09/26.
//

import Foundation

/// `POST /chat/get_messages` — `{booking_id, after_id?}`.
///
/// The API collection ships no sample response, so the thread is looked for
/// under every key the rest of this backend uses for a list. Whichever it
/// actually sends will land; the others cost nothing.
struct ChatMessagesResponse: Decodable {

    let result: String?
    let message: String?
    let messages: [ChatMessageDTO]

    private struct AnyKey: CodingKey {

        let stringValue: String
        var intValue: Int? { nil }

        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: AnyKey.self)

        func string(_ name: String) -> String? {
            guard let key = AnyKey(stringValue: name) else { return nil }
            return (try? container.decodeIfPresent(String.self, forKey: key)) ?? nil
        }

        result = string("result")
        message = string("message") ?? string("error")

        var thread: [ChatMessageDTO]?

        for name in ["data", "messages", "chat_messages", "chat", "message_data"] {

            guard let key = AnyKey(stringValue: name),
                  let decoded = try? container.decodeIfPresent([ChatMessageDTO].self, forKey: key) else {
                continue
            }

            thread = decoded
            break
        }

        messages = thread ?? []
    }
}

/// One row of `chat_messages`.
///
/// Every field is read through the same number-or-string helper the other models
/// in this app use: ids and flags arrive unquoted here as often as not, and a
/// single strict decode would throw away the whole thread.
struct ChatMessageDTO: Decodable {

    let id: Int
    let text: String
    let senderType: String
    let senderId: String?
    let sentAt: String?
    let isRead: Bool

    private struct AnyKey: CodingKey {

        let stringValue: String
        var intValue: Int? { nil }

        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: AnyKey.self)

        func text(_ names: String...) -> String? {

            for name in names {

                guard let key = AnyKey(stringValue: name) else { continue }

                if let value = try? container.decodeIfPresent(String.self, forKey: key),
                   !value.isEmpty {
                    return value
                }

                if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
                    return String(value)
                }

                if let value = try? container.decodeIfPresent(Bool.self, forKey: key) {
                    return value ? "1" : "0"
                }
            }

            return nil
        }

        // Without an id there is nothing to page `after_id` from, so this is the
        // one field worth refusing the row over.
        guard let idText = text("id", "message_id", "chat_id"),
              let id = Int(idText) else {

            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "chat message has no usable id")
            )
        }

        self.id = id
        self.text = text("message", "text", "msg", "chat_message") ?? ""
        self.senderType = (text("sender_type", "sender") ?? "").lowercased()
        self.senderId = text("sender_id")
        self.sentAt = text("created_at", "added_on", "date_time", "datetime", "time")

        let readFlag = text("is_read", "read", "read_status", "seen") ?? "0"
        self.isRead = ["1", "true", "yes"].contains(readFlag.lowercased())
    }
}

extension ChatMessageDTO {

    /// `"2026-09-16 10:21:00"` → `"10:21 AM"`, falling back to whatever came in
    /// rather than showing a blank timestamp.
    var displayTime: String {

        guard let sentAt, !sentAt.isEmpty else { return "" }

        for format in ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ss", "HH:mm:ss"] {

            let parser = DateFormatter()
            parser.locale = Locale(identifier: "en_US_POSIX")
            parser.calendar = Calendar(identifier: .gregorian)
            parser.dateFormat = format

            if let date = parser.date(from: sentAt) {

                let display = DateFormatter()
                display.locale = Locale(identifier: "en_US_POSIX")
                display.dateFormat = "h:mm a"
                return display.string(from: date)
            }
        }

        return sentAt
    }
}
