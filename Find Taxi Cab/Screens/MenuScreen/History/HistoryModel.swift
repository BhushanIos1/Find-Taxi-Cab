//
//  HistoryModel.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI

/// `POST /get_book_list` with `{client_id}`.
///
/// Android's `BookingHistoryList` declares only `booking_data` and null-checks it
/// rather than reading a `result` flag, so those stay optional here — a response
/// without them still decodes instead of dropping the whole list.
struct BookingHistoryResponse: Decodable {

    let result: String?
    let message: String?
    let bookingData: [BookingItem]?

    enum CodingKeys: String, CodingKey {
        case result
        case message
        case bookingData = "booking_data"
    }
}

/// One row of booking history. Keys taken from Android's `BookingHistory` model.
struct BookingItem: Identifiable, Decodable {

    let id = UUID()

    let assignStatus: String?
    let date: String?
    let time: String?
    let bookingId: String?
    let vehicleNo: String?
    let sourceAddress: String?
    let destinationAddress: String?
    let paidAmount: String?
    let paymentStatus: String?
    let totalAmount: String?
    let driverTip: String?
    let price: String?
    let specialMessage: String?
    let baseFare: String?
    let specialNeed: String?

    enum CodingKeys: String, CodingKey {
        case assignStatus = "assign_status"
        case date
        case time
        case bookingId = "booking_id"
        case vehicleNo = "vehicle_no"
        case sourceAddress = "source_addr"
        case destinationAddress = "destination_addr"
        case paidAmount = "paid_amount"
        case paymentStatus = "payment_status"
        case totalAmount = "total_amt"
        case driverTip = "driver_tip"
        case price
        case specialMessage = "manual_msg"
        case baseFare = "base_fair"
        case specialNeed = "special_need"
    }

    /// Hand-rolled because this row is mostly money and ids — `total_amt`,
    /// `base_fair`, `driver_tip`, `booking_id`, `payment_status` all commonly
    /// arrive as bare JSON numbers, and a plain `String?` decode throws on those,
    /// taking the entire history list down with it.
    init(from decoder: Decoder) throws {

        let c = try decoder.container(keyedBy: CodingKeys.self)

        func text(_ key: CodingKeys) -> String? {
            if let value = try? c.decodeIfPresent(String.self, forKey: key) { return value }
            if let value = try? c.decodeIfPresent(Int.self, forKey: key) { return String(value) }
            if let value = try? c.decodeIfPresent(Double.self, forKey: key) { return String(value) }
            return nil
        }

        assignStatus = text(.assignStatus)
        date = text(.date)
        time = text(.time)
        bookingId = text(.bookingId)
        vehicleNo = text(.vehicleNo)
        sourceAddress = text(.sourceAddress)
        destinationAddress = text(.destinationAddress)
        paidAmount = text(.paidAmount)
        paymentStatus = text(.paymentStatus)
        totalAmount = text(.totalAmount)
        driverTip = text(.driverTip)
        price = text(.price)
        specialMessage = text(.specialMessage)
        baseFare = text(.baseFare)
        specialNeed = text(.specialNeed)
    }

    /// For previews and mock rows.
    init(
        assignStatus: String?,
        date: String?,
        time: String?,
        bookingId: String?,
        vehicleNo: String?,
        sourceAddress: String?,
        destinationAddress: String?,
        paidAmount: String? = nil,
        paymentStatus: String? = nil,
        totalAmount: String?,
        driverTip: String? = nil,
        price: String? = nil,
        specialMessage: String? = nil,
        baseFare: String? = nil,
        specialNeed: String? = nil
    ) {
        self.assignStatus = assignStatus
        self.date = date
        self.time = time
        self.bookingId = bookingId
        self.vehicleNo = vehicleNo
        self.sourceAddress = sourceAddress
        self.destinationAddress = destinationAddress
        self.paidAmount = paidAmount
        self.paymentStatus = paymentStatus
        self.totalAmount = totalAmount
        self.driverTip = driverTip
        self.price = price
        self.specialMessage = specialMessage
        self.baseFare = baseFare
        self.specialNeed = specialNeed
    }
}

extension BookingItem {

    var dateTime: String {
        [date, time].compactMap { $0 }.joined(separator: "   ")
    }

    /// Android renders the row amount as `"£ " + total_amt`.
    var amountDisplay: String {
        "£ \(totalAmount ?? "0")"
    }

    /// Labels and colours copied from `BookingHistoryAdapter`'s switch, including
    /// its fallback of showing the raw status in black for anything unrecognised.
    var statusTitle: String {

        switch assignStatus?.lowercased() {

        case "abandon":      return "Abandoned"
        case "cancel":       return "Cancelled"
        case "complete":     return "Completed"
        case "assigned":     return "Assigned"
        case "accept":       return "Accepted"
        case "pickcustomer": return "PickCustomer"
        case "onboard":      return "Onboard"
        default:             return assignStatus ?? "—"
        }
    }

    var statusColor: Color {

        switch assignStatus?.lowercased() {

        case "abandon":  return Color(hex: "#F44336")
        case "cancel":   return Color(hex: "#3B78E7")
        case "complete": return Color(hex: "#0F9D58")
        case "assigned",
             "accept",
             "pickcustomer",
             "onboard":  return .cyan
        default:         return .black
        }
    }

    /// Android shows Pay only on a completed trip that hasn't been paid yet
    /// (`payment_status != "1"`); every other status hides it outright.
    var canPay: Bool {
        assignStatus?.lowercased() == "complete" && paymentStatus != "1"
    }
}
