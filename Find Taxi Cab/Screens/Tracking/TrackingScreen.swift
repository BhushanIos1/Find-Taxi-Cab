//
//  TrackingScreen.swift
//  Find Taxi Cab
//
//  Created by Claude on 27/08/26.
//

import SwiftUI

/// The rider-side counterpart of Android's `TrackingActivity` — live map with the
/// driver's polled position, the route to the pickup point, call/SMS, cancel, and
/// the push-driven end-of-trip flow (`book_cancelled` / `book_complete`).
///
/// Android shows a bare map here. This adds the driver card, addresses and the
/// distance/ETA/fare strip so the rider has something to watch while they wait —
/// all of it from data the app already holds, except the route, which comes from
/// the Directions API.
struct TrackingScreen: View {

    @EnvironmentObject
    private var router: AppRouter

    @EnvironmentObject
    private var toastManager: ToastManager

    let trip: TripContext

    @StateObject
    private var viewModel = TrackingViewModel()

    @State private var showCancelConfirm = false
    @State private var showSOSConfirm = false
    @State private var showDriverCancelledAlert = false

    /// Live trip status shown in the navigation bar, advanced by the
    /// `book_pickcustomer` / `book_onboard` pushes.
    @State private var tripStatusText = "Taxi Confirmed"

    /// Set once the trip completes and its fare lands — drives the receipt popover.
    @State private var receiptContext: ReceiptContext?

    // MARK: - Resolved trip values
    //
    // `trip` is whatever the screen that pushed us here happened to know. The
    // server is the better source once `get_bookdatatoclient` answers, so each of
    // these prefers the fetched value and keeps the passed-in one as a fallback.

    /// The route is drawn to the pickup point, so it needs coordinates. A trip
    /// resumed from `client_last_book` arrives without them — that response is
    /// addresses only — so fall back to what was saved when the booking was made.
    private var pickupCoordinate: Coordinate? {
        trip.pickupCoordinate ?? AuthManager.shared.activePickupCoordinate
    }

    private var destinationCoordinate: Coordinate? {
        trip.destinationCoordinate ?? AuthManager.shared.activeDropCoordinate
    }

    /// A trip in progress has no "back". Leaving mid-journey would drop the
    /// customer on Home with a booking they can no longer see or cancel, and the
    /// live map is the only place the trip exists.
    private var isTripInProgress: Bool {
        receiptContext == nil
    }

    private var driverName: String {

        let fetched = viewModel.driverInfo?.driverName ?? ""

        if !fetched.isEmpty { return fetched }

        return trip.driverName.isEmpty ? "Your Driver" : trip.driverName
    }

    private var vehicleNo: String {

        let fetched = viewModel.driverInfo?.vehicleNo ?? ""

        return fetched.isEmpty ? trip.vehicleNo : fetched
    }

    private var driverMobile: String {

        let fetched = viewModel.driverInfo?.driverMobile ?? ""

        return fetched.isEmpty ? trip.driverMobile : fetched
    }

    private var fareText: String {
        trip.fareText.isEmpty ? AuthManager.shared.activeFareText : trip.fareText
    }

    private var distanceText: String {
        trip.distanceText.isEmpty ? AuthManager.shared.activeDistanceText : trip.distanceText
    }

    var body: some View {

        VStack(spacing: 0) {

            driverCard

            GoogleMapView { mapView in
                viewModel.mapView = mapView
                viewModel.setRoute(
                    pickup: pickupCoordinate?.clLocationCoordinate,
                    destination: destinationCoordinate?.clLocationCoordinate
                )
            }

            tripSummary
        }
        .appNavigationBar(
            title: tripStatusText,
            leading: isTripInProgress ? .none : .back
        ) {
            router.pop()
        }
        .onAppear {

            // A trip resumed mid-journey missed the `book_onboard` push, so the
            // status the server reported is the only thing that says the customer
            // is already aboard.
            if trip.isOnboard {
                tripStatusText = "On Trip"
                viewModel.beginTripToDestination()
            }

            Task {

                // Whatever pushed us here may have had partial details — a resume
                // from `client_last_book`, say. Ask the server directly, then poll
                // with the driver id it confirms.
                let resolvedDriverId = await viewModel.loadDriverDetails(bookingId: trip.bookingId)

                let driverId = (resolvedDriverId?.isEmpty == false)
                    ? resolvedDriverId!
                    : trip.driverId

                guard !driverId.isEmpty else {
                    print("⚠️ TRACKING: no driver id — cannot poll driver location")
                    return
                }

                viewModel.startPolling(driverId: driverId)
            }
        }
        .onDisappear {
            // Both matter: the timer would otherwise keep firing against a screen
            // that is gone, and the markers would linger on the recycled map.
            viewModel.stopPolling()
            viewModel.clearMapOverlays()
        }
        .onReceive(NotificationManager.shared.$pendingNotification) { payload in

            guard let payload else { return }

            handleIncomingNotification(payload)

            NotificationManager.shared.pendingNotification = nil
        }
        .onChange(of: viewModel.cancelState) { state in

            guard let state else { return }

            switch state {

            case .success(let message):
                toastManager.showToast(type: .success, title: "Trip Cancelled", subtitle: message)
                endTrip()

            case .failure(let message):
                toastManager.showToast(type: .error, title: "Failed", subtitle: message)
            }

            viewModel.cancelState = nil
        }
        .alert("Cancel Trip?",
               isPresented: $showCancelConfirm) {

            Button("No", role: .cancel) { }

            Button("Yes, Cancel", role: .destructive) {
                viewModel.cancelBooking(bookingId: trip.bookingId)
            }
        } message: {
            Text("Are you sure you want to cancel this trip?")
        }
        .alert("Emergency Call",
               isPresented: $showSOSConfirm) {

            Button("Cancel", role: .cancel) { }

            Button("Call") {
                PhoneHelper.call("01132772299")
            }
        } message: {
            Text("Call the emergency line on \("01132772299")?")
        }
        .alert("Trip Cancelled",
               isPresented: $showDriverCancelledAlert) {

            Button("OK") {
                endTrip()
            }
        } message: {
            Text("The driver cancelled this trip.")
        }
        // The fare arrives from `get_fair` on the `book_complete` push; pairing it
        // with the booking id here gives the receipt everything `do_payment` needs.
        .onChange(of: viewModel.fareDetails) { fare in

            guard let fare else { return }

            receiptContext = ReceiptContext(bookingId: trip.bookingId, fare: fare)
        }
        .receiptPopup(context: $receiptContext) {
            viewModel.fareDetails = nil
            endTrip()
        }
        .overlay(
            GlobalToastView()
                .environmentObject(toastManager)
        )
    }
}

// MARK: - Driver card

private extension TrackingScreen {

    var driverCard: some View {

        VStack(spacing: 14) {

            driverRow
            contactButtons
        }
        .padding(16)
        .background(Color(.systemBackground))
    }

    var driverRow: some View {

        HStack(spacing: 14) {

            avatar

            VStack(alignment: .leading, spacing: 3) {

                Text(driverName)
                    .font(AppFont.font(.semiBold, size: 19))
                    .lineLimit(1)

                Text(vehicleNo.isEmpty ? "—" : vehicleNo)
                    .font(AppFont.font(.regular, size: 15))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
    }

    /// The backend doesn't return a driver photo, so this stands in with their
    /// initials rather than leaving a grey circle.
    var avatar: some View {

        ZStack {

            Circle()
                .fill(AppColors.primaryYellow.opacity(0.2))

            Text(driverInitials)
                .font(AppFont.font(.semiBold, size: 20))
                .foregroundStyle(AppColors.primaryYellow)
        }
        .frame(width: 52, height: 52)
    }

    var driverInitials: String {

        let initials = driverName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }

        return initials.isEmpty ? "?" : String(initials).uppercased()
    }

    var contactButtons: some View {

        HStack(spacing: 12) {

            Button {
                PhoneHelper.call(driverMobile)
            } label: {
                contactLabel(
                    title: "Call Driver",
                    systemImage: "phone.fill",
                    foreground: .white,
                    background: AppColors.greenAppColor
                )
            }
            .disabled(driverMobile.isEmpty)

            Button {
                messageDriver()
            } label: {
                contactLabel(
                    title: "Message",
                    systemImage: "message.fill",
                    foreground: Color(.label),
                    background: Color(.systemBackground),
                    hasBorder: true
                )
            }
            .disabled(driverMobile.isEmpty)
        }
        .opacity(driverMobile.isEmpty ? 0.5 : 1)
    }

    func contactLabel(
        title: String,
        systemImage: String,
        foreground: Color,
        background: Color,
        hasBorder: Bool = false
    ) -> some View {

        HStack(spacing: 8) {

            Image(systemName: systemImage)
            Text(title)
                .font(AppFont.font(.medium, size: 16))
        }
        .foregroundStyle(foreground)
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(AppColors.uberBorder, lineWidth: hasBorder ? 1 : 0)
        )
    }
}

// MARK: - Trip summary

private extension TrackingScreen {

    var tripSummary: some View {

        VStack(spacing: 0) {

            addressRow(
                icon: "mappin.circle.fill",
                tint: .red,
                title: "Pickup:",
                value: trip.pickupAddress
            )

            Divider()

            addressRow(
                icon: "mappin.circle.fill",
                tint: AppColors.greenAppColor,
                title: "Drop-off:",
                value: trip.destinationAddress
            )

            Divider()

            metricsRow
                .padding(.vertical, 12)

            actionButtons
        }
        .background(Color(.systemBackground))
    }

    @ViewBuilder
    func addressRow(
        icon: String,
        tint: Color,
        title: String,
        value: String
    ) -> some View {

        if !value.isEmpty {

            HStack(alignment: .top, spacing: 10) {

                Image(systemName: icon)
                    .foregroundStyle(tint)

                Text(title)
                    .font(AppFont.font(.semiBold, size: 14))

                Text(value)
                    .font(AppFont.font(.regular, size: 14))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    /// Distance and fare are what the rider was quoted when they picked the
    /// vehicle; the ETA — and a live distance once it arrives — comes from the
    /// Directions call against the driver's current position.
    var metricsRow: some View {

        HStack(spacing: 6) {

            metric(title: distanceLabel, value: viewModel.routeDistanceText ?? distanceText)
            separator(isVisible: viewModel.etaText != nil)
            metric(title: etaLabel, value: viewModel.etaText ?? "")
            separator(isVisible: !fareText.isEmpty)
            metric(title: "Fare:", value: fareText)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
    }

    /// "Distance" before pickup is the taxi's approach; afterwards it is what is
    /// left of the customer's own journey.
    var distanceLabel: String {
        viewModel.phase == .toDestination ? "Remaining:" : "Distance:"
    }

    var etaLabel: String {
        viewModel.phase == .toDestination ? "Arrive in:" : "ETA:"
    }

    @ViewBuilder
    func metric(title: String, value: String) -> some View {

        if !value.isEmpty {

            HStack(spacing: 4) {

                Text(title)
                    .font(AppFont.font(.regular, size: 13))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(AppFont.font(.semiBold, size: 13))
            }
        }
    }

    @ViewBuilder
    func separator(isVisible: Bool) -> some View {

        if isVisible {
            Text("•")
                .font(AppFont.font(.regular, size: 13))
                .foregroundStyle(.secondary)
        }
    }

    var actionButtons: some View {

        HStack(spacing: 12) {

            // Once the OTP is verified and the customer is in the car, there is
            // nothing left to cancel — the trip is happening. The driver app
            // drops its CANCEL at the same moment for the same reason.
            if canCancel {

                Button {
                    showCancelConfirm = true
                } label: {
                    actionLabel(
                        title: viewModel.isCancelling ? "Cancelling…" : "Cancel Ride",
                        systemImage: "xmark",
                        background: AppColors.grayDarkColor
                    )
                }
                .disabled(viewModel.isCancelling)
                .transition(.opacity)
            }

            // SOS stays throughout — mid-journey is exactly when it matters.
            Button {
                showSOSConfirm = true
            } label: {
                actionLabel(
                    title: "SOS",
                    systemImage: "exclamationmark.circle.fill",
                    background: .red
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: canCancel)
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 12)
    }

    /// Cancelling is only possible while the taxi is still on its way.
    var canCancel: Bool {
        viewModel.phase == .toPickup
    }

    func actionLabel(
        title: String,
        systemImage: String,
        background: Color
    ) -> some View {

        HStack(spacing: 8) {

            Image(systemName: systemImage)
            Text(title)
                .font(AppFont.font(.medium, size: 16))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Notifications

private extension TrackingScreen {

    /// Mirrors Android's `TrackingActivity.myReceiver` — `book_cancelled` shows the
    /// driver-cancelled dialog, `book_complete` fetches the fare (§ `getFairDetails()`).
    func handleIncomingNotification(_ payload: NotificationPayload) {

        switch NotificationManager.shared.customerAction(for: payload) {

        case .driverPickingUp:
            // `book_pickcustomer` — the driver has set off to collect the rider.
            tripStatusText = "Driver On The Way"

        case .driverOnboard:
            // `book_onboard` — journey started. Re-point the map at the drop-off
            // so the ETA and remaining distance describe the journey rather than
            // the wait.
            tripStatusText = "On Trip"
            viewModel.beginTripToDestination()

        case .tripCancelledByDriver:
            viewModel.stopPolling()
            showDriverCancelledAlert = true

        case .tripCompleted:
            viewModel.stopPolling()
            viewModel.getFareDetails(bookingId: trip.bookingId)

        default:
            break
        }
    }

    /// Cancelled, completed or called off by the driver — stop the polling and
    /// forget the trip before heading home, so its coordinates and fare can't
    /// surface on the next one.
    func endTrip() {

        viewModel.stopPolling()

        AuthManager.shared.bookingID = ""
        AuthManager.shared.saveActiveTrip(
            pickupLat: 0,
            pickupLng: 0,
            dropLat: 0,
            dropLng: 0,
            fareText: "",
            distanceText: ""
        )

        router.popTo(.home)
    }

    func messageDriver() {

        guard !driverMobile.isEmpty,
              let url = URL(string: "sms:\(driverMobile)") else {
            return
        }

        UIApplication.shared.open(url)
    }
}

#Preview {
    TrackingScreen(
        trip: TripContext(
            bookingId: "12345",
            driverId: "9",
            driverName: "John Singh",
            vehicleNo: "WB34AB1234",
            driverMobile: "07123456789",
            pickupAddress: "18 Swan Ln, Huddersfield",
            destinationAddress: "1 New St, Huddersfield",
            fareText: "£12"
        )
    )
}
