//
//  NotificationManager.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 24/08/26.
//

import Foundation
import UserNotifications

/// Single entry point for every inbound push, whatever state the app was in when it
/// arrived — the iOS equivalent of the Android app's `MyFireBaseMessagingService` +
/// its `INTENT_FILTER` local broadcast rolled into one. `AppDelegate` forwards every
/// remote notification callback here; screens observe `pendingNotification` instead
/// of talking to push APIs directly.
final class NotificationManager: NSObject, ObservableObject {

    static let shared = NotificationManager()

    @Published var pendingNotification: NotificationPayload?

    private override init() {
        super.init()
    }

    func handle(userInfo: [AnyHashable: Any]) {

        let payload = NotificationPayload(
            userInfo: userInfo
        )

        print("""

        🔔 PUSH NOTIFICATION
        =========================
        Status: \(payload.status)
        Booking ID: \(payload.bookingId ?? "nil")
        Title: \(payload.title ?? "nil")
        Message: \(payload.message ?? "nil")
        =========================

        """)

        presentLocalAlertIfNeeded(for: payload, rawUserInfo: userInfo)

        DispatchQueue.main.async {
            self.pendingNotification = payload
        }
    }
}

private extension NotificationManager {

    /// Status-driven pushes (`book_accept`, `book_pickcustomer`, `nodriver`,
    /// `book_cancelled`, `book_complete`, `block`) are sent silent — `content-available`
    /// only, no `aps.alert` — the same reason the Android app sends FCM *data*
    /// messages instead of *notification* messages: it's the only way to reach the
    /// app reliably while backgrounded. iOS shows nothing for a silent push on its
    /// own, so — like `MyFireBaseMessagingService.sendNotification()` on Android —
    /// the app builds its own heads-up alert from the payload's `title`/`message`.
    func presentLocalAlertIfNeeded(for payload: NotificationPayload, rawUserInfo: [AnyHashable: Any]) {

        let alreadyDisplayedBySystem = (rawUserInfo["aps"] as? [String: Any])?["alert"] != nil

        guard !alreadyDisplayedBySystem,
              let title = payload.title,
              let body = payload.message else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = rawUserInfo

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}

/// What a given push should make the rider's screen do — the counterpart of the
/// Android app's `changeFlow(status)` switch, spread across `MainActivity`,
/// `CabSelectionActivity`, and `TrackingActivity`. Kept here as the single mapping
/// so whichever screen ends up owning the booking-in-progress flow can switch on
/// one enum instead of re-deriving this from raw status strings.
enum CustomerNotificationAction {
    case driverAccepted
    case driverPickingUp
    case driverOnboard
    case tripCompleted
    case tripCancelledByDriver
    case noDriverAvailable
    case accountBlocked
    case none
}

extension NotificationManager {

    func customerAction(for payload: NotificationPayload) -> CustomerNotificationAction {

        switch payload.status {

        case .bookAccept:
            return .driverAccepted

        case .bookPickCustomer:
            return .driverPickingUp

        case .bookOnboard:
            return .driverOnboard

        case .bookComplete:
            return .tripCompleted

        case .bookCancelled:
            return .tripCancelledByDriver

        case .noDriver:
            return .noDriverAvailable

        case .blockAccount:
            return .accountBlocked

        case .unknown:
            return .none
        }
    }
}
