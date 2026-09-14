//
//  NotificationStatus.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 24/08/26.
//

/// Raw values must match the Android client exactly — see `MainActivity.changeFlow()`
/// and the `TrackingActivity`/`CabSelectionActivity` receivers in the rider Android app.
enum NotificationStatus: String {

    // Customer
    case bookAccept = "book_accept"
    case bookPickCustomer = "book_pickcustomer"
    case bookOnboard = "book_onboard"
    case bookComplete = "book_complete"
    case bookCancelled = "book_cancelled"
    case noDriver = "nodriver"
    case blockAccount = "block_account"

    case unknown
}

extension NotificationStatus {

    /// The API doc documents the blocked-account status as `block_account`, but the
    /// Android client compares against `"block"` (`R.string.block_status`) and would
    /// ignore `block_account` entirely. Since the two disagree and guessing wrong
    /// means a blocked account is never surfaced, both spellings are accepted.
    private static let blockedAccountAliases: Set<String> = ["block_account", "block"]

    init(value: String?) {

        let raw = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if Self.blockedAccountAliases.contains(raw) {
            self = .blockAccount
            return
        }

        self = NotificationStatus(rawValue: raw) ?? .unknown
    }
}
