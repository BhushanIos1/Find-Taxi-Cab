//
//  ChatViewModel.swift
//  Find Taxi Cab
//
//  Created by Claude on 16/09/26.
//

import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {

    /// Everything the thread shows: confirmed messages followed by anything still
    /// in flight.
    @Published private(set) var messages: [ChatMessage] = []

    @Published private(set) var isLoadingInitial = false
    @Published var errorMessage: String?

    private let bookingId: String

    /// Which side this app is. Decides `isSender` on every row and what
    /// `send_message` / `mark_read` report themselves as.
    private let mySenderType: String

    /// Confirmed by the server, keyed in arrival order.
    private var confirmed: [ChatMessage] = []

    /// Sent from here, not yet seen coming back from the server.
    private var pending: [ChatMessage] = []

    /// Only the first load shows a spinner; later polls must not flash the UI.
    private var hasLoadedOnce = false

    private var pollTask: Task<Void, Never>?

    /// 5s, matching the driver-location poll the tracking screen already runs.
    private static let pollInterval: Duration = .seconds(5)

    init(bookingId: String, mySenderType: String) {
        self.bookingId = bookingId
        self.mySenderType = mySenderType
    }

    deinit {
        pollTask?.cancel()
    }
}

// MARK: - Polling

extension ChatViewModel {

    /// A single cancellable loop rather than a repeating `Timer`.
    ///
    /// The loop owns its own cadence, so a slow response delays the next request
    /// instead of stacking another on top of it, and cancellation is immediate —
    /// a `Timer` would keep its target alive until invalidated.
    func startPolling() {

        stopPolling()

        pollTask = Task { [weak self] in

            while !Task.isCancelled {

                await self?.fetchNewMessages()

                guard let interval = await self?.pollingInterval else { return }

                try? await Task.sleep(for: interval)
            }
        }
    }

    func stopPolling() {
        pollTask?.cancel()
        pollTask = nil
    }

    private var pollingInterval: Duration {
        Self.pollInterval
    }
}

// MARK: - Loading

private extension ChatViewModel {

    func fetchNewMessages() async {

        if !hasLoadedOnce {
            isLoadingInitial = true
        }

        defer {
            isLoadingInitial = false
            hasLoadedOnce = true
        }

        do {

            // Always the whole thread, not `after_id`. The API caps a thread at
            // 200 messages — cheap to re-fetch in full — and that's the only way
            // to notice a read-receipt flip on a message that was already on
            // screen. `after_id` is a high-water mark: once a row's `id` has been
            // seen it is never asked about again, so a tick going from single to
            // double after the other party reads it would never be reflected
            // until the screen was torn down and rebuilt from scratch (which is
            // exactly why leaving and reopening Chat "fixed" it).
            let response: ChatMessagesResponse = try await APIClient.shared.request(
                CustomerAPI.chatMessages(bookingId: bookingId, afterId: ""),
                responseType: ChatMessagesResponse.self
            )

            apply(response.messages)

        } catch {

            // A dropped poll is not worth an alert — the next one is five
            // seconds away and the thread on screen is still valid.
            print("❌ CHAT POLL ERROR:", error)
        }
    }

    func apply(_ incoming: [ChatMessageDTO]) {

        let hadMessages = !confirmed.isEmpty

        // A wholesale replace, not a merge — this is what lets a read-receipt
        // change on an existing row actually show up, and it's simple: every
        // poll is just "here is the truth right now."
        confirmed = incoming.map { ChatMessage(dto: $0, mySenderType: mySenderType) }

        // Anything of ours the server now has is no longer "in flight."
        pending.removeAll { pendingMessage in
            confirmed.contains { $0.isSender && $0.text == pendingMessage.text }
        }

        rebuild()

        // Only worth telling the server once there's something to mark — an
        // empty thread has nothing for `mark_read` to act on.
        if hadMessages || !confirmed.isEmpty {
            markRead()
        }
    }

    func rebuild() {
        messages = confirmed + pending
    }

    /// Clears the other party's unread flags — this is what drives their double
    /// tick, so it runs whenever new messages land rather than only on open.
    func markRead() {

        // `[weak self]`: this fires on every poll tick, and without it each call
        // keeps the whole view model alive for the round trip even after the
        // screen — and its `@StateObject` owner — is long gone. A stray one
        // finishing late is harmless; the leak is if several stack up on a slow
        // connection, each pinning a copy of everything this object holds.
        Task { [weak self] in

            guard let bookingId = self?.bookingId else { return }

            do {

                let _: CommonResponse = try await APIClient.shared.request(
                    CustomerAPI.markChatRead(bookingId: bookingId),
                    responseType: CommonResponse.self
                )

            } catch {
                print("❌ CHAT MARK READ ERROR:", error)
            }
        }
    }
}

// MARK: - Sending

extension ChatViewModel {

    func send(_ text: String) {

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else { return }

        // Shown immediately, dimmed, so the thread reacts to the tap rather than
        // waiting on a round trip.
        pending.append(
            ChatMessage(
                text: trimmed,
                time: Self.currentTime(),
                isSender: true,
                isRead: false,
                isPending: true
            )
        )

        rebuild()

        // `[weak self]` — sending survives the screen closing (the server should
        // still get the message), but nothing after that should hold the view
        // model alive just to update UI state nobody will see.
        Task { [weak self] in

            guard let self else { return }

            do {

                let response: CommonResponse = try await APIClient.shared.request(
                    CustomerAPI.sendChatMessage(bookingId: bookingId, message: trimmed),
                    responseType: CommonResponse.self
                )

                if response.result?.lowercased() == "success" {

                    // Don't wait out the poll — the sender is watching this one.
                    await fetchNewMessages()

                } else {

                    // The server closes chat once the booking is complete or
                    // cancelled; that refusal arrives here.
                    failPending(trimmed, reason: response.message ?? "Message could not be sent.")
                }

            } catch {

                print("❌ CHAT SEND ERROR:", error)
                failPending(trimmed, reason: "Message could not be sent. Check your connection.")
            }
        }
    }

    private func failPending(_ text: String, reason: String) {

        if let index = pending.firstIndex(where: { $0.text == text }) {
            pending.remove(at: index)
        }

        rebuild()
        errorMessage = reason
    }

    static func currentTime() -> String {

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
}
