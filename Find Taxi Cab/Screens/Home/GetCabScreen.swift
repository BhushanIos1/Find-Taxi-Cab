//
//  GetCabScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 09/03/26.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct GetCabScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    let fromLat: Double
    let fromLong: Double
    let toLat: Double
    let toLong: Double
    
    let pickupAddress: String
    let destinationAddress: String
    let disability: String
    let numberOfPassenger: Int
    
    @State private var selectedDate: Date = .now
    @State private var bookingType: BookingType = .immediate
    @State private var passengers: Int
    @State private var showDatePicker = false
    
    @State private var showAlert = false
    @State private var alertErrorMessage = ""

    /// True from the moment `createBooking()` succeeds until a `book_accept` /
    /// `nodriver` push resolves it — Android shows this as dialogs on top of
    /// `CabSelectionActivity` while its `myReceiver` waits for the same statuses.
    @State private var isSearchingForDriver = false

    /// What the waiting overlay says while the search is still running.
    @State private var searchingStatusText = "Searching for a nearby driver…"

    /// Set by the `book_accept` push — swaps the spinner for the success card.
    /// Android's `showAcceptDialog()` starts a 5s timer but its dismiss call is
    /// commented out, so the dialog stays up until `book_pickcustomer` opens
    /// tracking. Same here: nothing clears this except that transition.
    @State private var showBookingAccepted = false

    /// The row the rider tapped. Its `price` and `distance` are what the tracking
    /// screen shows as Fare and Distance — the server has already priced the trip
    /// at this point, so there is nothing else to ask it for.
    @State private var selectedVehicle: VehicleModel?

    /// The 5s hold on the "Booking Accepted" card. Held so it can be cancelled —
    /// if `book_pickcustomer` lands first, the handoff happens immediately and
    /// this must not fire a second one behind it.
    @State private var acceptedHandoffTask: Task<Void, Never>?

    /// Tracking is entered exactly once per booking, from whichever trigger gets
    /// there first.
    @State private var hasHandedOffToTracking = false

    /// Where the shared `AndroidAlertView`'s OK button sends the rider — vehicle-list
    /// failures go back to booking history (existing behavior); a push-driven
    /// no-driver/blocked case should return to the search screen instead so they can retry.
    @State private var alertDismissRoute: AppRoute = .booking
    
    private var bookingDate: String {
        bookingType == .immediate
        ? Date().apiDate
        : selectedDate.apiDate
    }
    
    private var bookingTime: String {
        bookingType == .immediate
        ? Date().apiTime
        : selectedDate.apiTime
    }
    
    @StateObject
    private var viewModel = BookingViewModel()
    
    init(
        pickupAddress: String,
        destinationAddress: String,
        fromLat: Double,
        fromLong: Double,
        toLat: Double,
        toLong: Double,
        disability: String,
        numberOfPassenger: Int
    ) {
        self.pickupAddress = pickupAddress
        self.destinationAddress = destinationAddress
        self.fromLat = fromLat
        self.fromLong = fromLong
        self.toLat = toLat
        self.toLong = toLong
        self.disability = disability
        self.numberOfPassenger = numberOfPassenger
        _passengers = State(initialValue: numberOfPassenger)
    }
    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 0) {
                
                headerView
                
                buttonSection
                
                vehicleList
            }
            
            if viewModel.isLoading {

                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()

                LoadingIndicator(
                    animation: .circleTrim,
                    color: AppColors.primaryYellow,
                    size: .medium,
                    speed: .normal
                )
            }

            if isSearchingForDriver {

                Color.black.opacity(0.45)
                    .ignoresSafeArea()

                if showBookingAccepted {

                    SuccessAlertView(message: "Booking Accepted")
                        .transition(.scale.combined(with: .opacity))

                } else {

                    VStack(spacing: 16) {

                        LoadingIndicator(
                            animation: .circleTrim,
                            color: AppColors.primaryYellow,
                            size: .medium,
                            speed: .normal
                        )

                        Text(searchingStatusText)
                            .font(AppFont.font(.medium, size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .animation(.easeInOut, value: searchingStatusText)
                    }
                }
            }
        }
        .appNavigationBar(
            title: "Select Cab",
            leading: .back
        ) {
            router.pop()
        }
        .onAppear {
            loadVehicles()
        }
        .onChange(of: bookingType) { type in
            if type == .immediate {
                loadVehicles()
            } else {
                showDatePicker = true
            }
        }
        .onChange(of: viewModel.bookingState) { state in

            guard let state else { return }

            switch state {

            case .success:
                // Booking created — now wait for the driver-side push
                // (book_accept / nodriver / book_pickcustomer) instead of
                // dismissing immediately.
                viewModel.errorMessage = nil

                if viewModel.bookingId != nil {
                    searchingStatusText = "Searching for a nearby driver…"
                    // A second booking in the same session must start on the
                    // spinner, not on the previous trip's success card.
                    showBookingAccepted = false
                    hasHandedOffToTracking = false
                    withAnimation {
                        isSearchingForDriver = true
                    }
                }

            case .failure(let message):

                alertErrorMessage = message
                alertDismissRoute = .booking

                withAnimation {
                    showAlert = true
                }
            }

            DispatchQueue.main.async {
                viewModel.bookingState = nil
            }
        }
        .onReceive(NotificationManager.shared.$pendingNotification) { payload in

            guard let payload else { return }

            handleIncomingNotification(payload)

            NotificationManager.shared.pendingNotification = nil
        }
        .onChange(of: viewModel.trackingDriverInfo) { info in

            guard let info else { return }

            handOffToTracking(with: info)
        }
        .onDisappear {
            acceptedHandoffTask?.cancel()
            acceptedHandoffTask = nil
        }
        .sheet(isPresented: $showDatePicker) {
            datePickerSheet
        }
        .overlay {
            
            ZStack {
                
                if showAlert {
                    
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    AndroidAlertView(
                        message: alertMessage,
                        buttonTitle: "OK"
                    ) {
                        withAnimation {
                            showAlert = false
                            router.popTo(alertDismissRoute)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: showAlert)
        }
    }

    private var alertMessage: String {
        alertErrorMessage.isEmpty
            ? "Sorry No Vehicle Available. Please Try Later"
            : alertErrorMessage
    }
    
    private func loadVehicles() {
        
        viewModel.getVehicleList(
            latFrom: "\(fromLat)",
            longFrom: "\(fromLong)",
            latTo: "\(toLat)",
            longTo: "\(toLong)",
            date: bookingDate,
            time: bookingTime,
            passengers: "\(passengers)",
            specialNeed: disability
        )
    }
}

private extension GetCabScreen {
    
    var headerView: some View {
        
        BookingPreviewHeader(
            pickupAddress: .constant(pickupAddress),
            destinationAddress: .constant(destinationAddress),
            selectedDate: $selectedDate,
            selectedType: $bookingType,
            onAdvanceTap: { showDatePicker = true },
            showBookingType: true
        )
        .padding(20)
    }
}

private extension GetCabScreen {

    /// Mirrors Android's `MainActivity.changeFlow(status)` for the three statuses
    /// that can arrive while the rider is waiting on this screen for a match.
    func handleIncomingNotification(_ payload: NotificationPayload) {

        switch NotificationManager.shared.customerAction(for: payload) {

        case .noDriverAvailable:
            isSearchingForDriver = false
            alertErrorMessage = "Sorry, no driver was available for this trip. Please try again."
            alertDismissRoute = .home
            withAnimation { showAlert = true }

        case .driverAccepted:
            // Android's `showAcceptDialog()` — dialog_booking_accepted.
            withAnimation {
                showBookingAccepted = true
            }

            scheduleTrackingHandoff()

        case .driverPickingUp:
            searchingStatusText = "Your driver is on the way…"
            guard let bookingId = viewModel.bookingId else { return }
            viewModel.getBookingDataToClient(bookingId: bookingId)

        case .accountBlocked:
            isSearchingForDriver = false
            alertErrorMessage = "Your account has been blocked by the admin."
            alertDismissRoute = .home
            withAnimation { showAlert = true }

        default:
            break
        }
    }
}

private extension GetCabScreen {

    var disabilityText: some View {
        
        Text(disability.isEmpty ? "No Special Needs" : disability)
            .padding(.horizontal)
            .padding(.top, 8)
    }
}

private extension GetCabScreen {
    
    var vehicleList: some View {
        
        ScrollView(showsIndicators: false) {
            
            LazyVStack(spacing: 20) {
                
                ForEach(viewModel.availableVehicles) { car in
                    
                    Button {
                        handleCarSelection(car)
                    } label: {
                        TaxiCarCell(car: car)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
}

private extension GetCabScreen {
    
    /// Everything the tracking screen needs, assembled from what this screen
    /// already knows plus the driver details the push brought back.
    func trackingContext(for info: TrackingDriverInfo?) -> TripContext {
        
        TripContext(
            bookingId: AuthManager.shared.bookingID,
            driverId: info?.driverId ?? "",
            driverName: info?.driverName ?? "",
            vehicleNo: info?.vehicleNo ?? "",
            driverMobile: info?.driverMobile ?? "",
            pickupAddress: pickupAddress,
            destinationAddress: destinationAddress,
            pickupCoordinate: Coordinate(latitude: fromLat, longitude: fromLong),
            destinationCoordinate: Coordinate(latitude: toLat, longitude: toLong),
            fareText: selectedVehicle.map { "£\($0.price)" } ?? "",
            // No unit: nothing in either app labels `vehicle_list.distance`, and
            // `TaxiCarCell` shows it bare too. The Directions result replaces this
            // within a few seconds with a properly formatted, locale-aware value.
            distanceText: selectedVehicle.map { String(format: "%.1f", $0.distance) } ?? ""
        )
    }
    
    /// Holds the "Booking Accepted" card for five seconds — the same beat as
    /// Android's `CountDownTimer(5000, 1000)` in `showAcceptDialog()` — then moves
    /// the rider on to tracking.
    func scheduleTrackingHandoff() {
        
        guard !hasHandedOffToTracking else { return }
        
        acceptedHandoffTask?.cancel()
        
        acceptedHandoffTask = Task {
            
            try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
            
            guard !Task.isCancelled else { return }
            
            // No driver details yet at `book_accept` — TrackingScreen fetches its
            // own from `get_bookdatatoclient`, so the booking id is enough.
            handOffToTracking(with: nil)
        }
    }
    
    /// Leaves the booking flow behind: the stack becomes Home → Tracking, so Back
    /// from tracking returns to Home rather than to the cab picker for a trip the
    /// rider has already booked.
    ///
    /// Called from two places — the 5s timer above and the `book_pickcustomer`
    /// driver-data fetch — whichever arrives first wins.
    func handOffToTracking(with info: TrackingDriverInfo?) {
        
        guard !hasHandedOffToTracking else { return }
        hasHandedOffToTracking = true
        
        acceptedHandoffTask?.cancel()
        acceptedHandoffTask = nil
        
        showBookingAccepted = false
        isSearchingForDriver = false
        
        router.replaceStack(with: .tracking(trackingContext(for: info)))
    }
    
    func handleCarSelection(_ car: VehicleModel) {
        print("Selected Car:", car)
        
        selectedVehicle = car
        
        // Remembered because neither `client_last_book` nor `get_bookdatatoclient`
        // returns coordinates — without this, reopening the app mid-trip leaves
        // the tracking map with nowhere to draw the route to.
        AuthManager.shared.saveActiveTrip(
            pickupLat: fromLat,
            pickupLng: fromLong,
            dropLat: toLat,
            dropLng: toLong,
            fareText: "£\(car.price)",
            distanceText: String(format: "%.1f", car.distance)
        )
        
        viewModel.createBooking(
            pickupAddress: pickupAddress,
            dropAddress: destinationAddress,
            vehicleType: "\(car.seater)",
            passengers: "\(passengers)",
            specialNeed: disability,
            latFrom: "\(fromLat)",
            longFrom: "\(fromLong)",
            latTo: "\(toLat)",
            longTo: "\(toLong)",
            date: bookingType == .immediate ? "" : selectedDate.apiDate,
            time: bookingType == .immediate ? "" : selectedDate.apiTime
        )
    }
}

private extension GetCabScreen {
    
    var datePickerSheet: some View {
        
        VStack(spacing: 10) {
            
            Text("Select Pickup Time")
                .font(AppFont.font(.medium, size: 16))
            
            DatePicker(
                "",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            
            Button {
                showDatePicker = false
                loadVehicles()
            } label: {
                Text("Done")
                    .primaryButtonStyle()
            }
        }
        .padding()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

private extension GetCabScreen {
    
    var buttonSection: some View {
        
        Text("ESTIMATED FARE")
            .font(AppFont.font(.medium, size: 18))
            .foregroundColor(colorScheme == .dark ? .black : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(colorScheme == .dark ? Color.white : Color.black)
    }
}
