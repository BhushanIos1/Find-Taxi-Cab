//
//  HomeScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 28/02/26.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct HomeScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @EnvironmentObject
    private var toastManager: ToastManager
    
    @State private var presentSideMenu = false
    
    @State private var showShareSheet = false
    @State private var showLogoutAlert = false
    
    @StateObject
    private var locationService = LocationService()
    
    @State private var pickupAddress = ""
    @State private var destinationAddress = ""
    
    @State private var currentLat = Double()
    @State private var currentLong = Double()
    
    @State private var destinationLat = Double()
    @State private var destinationLong = Double()
    
    @State private var showPlaceSearch = false
    @State private var searchType: SearchType = .pickup
    
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    
    @StateObject
    private var viewModel = RegisterViewModel()
    
    @StateObject
    private var homeViewModel = HomeViewModel()
    
    @State private var locationTimer = Timer.publish(every: 20, on: .main, in: .common).autoconnect()

    @State private var showBlockedAlert = false

    @StateObject
    private var bookingViewModel = BookingViewModel()

    /// Resume is a launch-time question, not something to re-ask every time this
    /// screen reappears — otherwise popping back from tracking would immediately
    /// push the rider into it again.
    @State private var hasCheckedForActiveTrip = false
    
    var body: some View {
        
        ZStack {
            
            GoogleMapView()
                .ignoresSafeArea()
            
            VStack {
                
                RideLocationCard(
                    pickupAddress: $pickupAddress,
                    destinationAddress: $destinationAddress,
                    pickupTap: {
                        searchType = .pickup
                        showPlaceSearch = true
                    },
                    destinationTap: {
                        searchType = .destination
                        showPlaceSearch = true
                    }
                )
                .padding(20)
                
                Spacer()
                bottomSection
            }
            
            if viewModel.isLoading {
                
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
                
                LoadingIndicator(
                    animation: .circleTrim,
                    color: AppColors.primaryYellow,
                    size: .medium,
                    speed: .normal
                )
            }
        }
        .appNavigationBar(
            title: "Home",
            leading: .menu
        ) {
            withAnimation(.easeInOut) {
                presentSideMenu.toggle()
            }
        }
        .onAppear {
            locationService.requestLocation()
            locationService.startTracking()

            openPendingChatIfNeeded()

            // Closed the app mid-trip? Go straight back to live tracking, the
            // automatic version of Android's BookingPage "Continue" button.
            if !hasCheckedForActiveTrip {
                hasCheckedForActiveTrip = true
                bookingViewModel.restoreActiveTrip()
            }
        }
        .onChange(of: bookingViewModel.restorableTrip) { trip in

            guard let trip, let bookingId = trip.bookingId else { return }

            bookingViewModel.restorableTrip = nil

            // `client_last_book` returns the addresses but no coordinates, so a
            // resumed trip shows the driver live without a drawn route.
            router.push(
                .tracking(
                    TripContext(
                        bookingId: bookingId,
                        driverId: trip.driverId ?? "",
                        driverName: trip.driverName ?? "",
                        vehicleNo: trip.vehicleNo ?? "",
                        driverMobile: trip.driverMobile ?? "",
                        pickupAddress: trip.sourceAddress ?? "",
                        destinationAddress: trip.destinationAddress ?? "",
                        assignStatus: trip.assignStatus ?? ""
                    )
                )
            )
        }
        .onChange(of: locationService.currentAddress) { address in
            
            pickupAddress = address
            
            if let location = locationService.currentLocation {
                currentLat = location.coordinate.latitude
                currentLong = location.coordinate.longitude
            }
        }
        .onChange(of: homeViewModel.homeState) { state in
            
            guard let state else { return }
            
            switch state {
                
            case .success(let message):
                
                toastManager.showToast(
                    type: .success,
                    title: "Success",
                    subtitle: message
                )
                
                viewModel.errorMessage = nil
                
            case .failure(let message):
                
                toastManager.showToast(
                    type: .error,
                    title: "Failed",
                    subtitle: message
                )
            }
            
            DispatchQueue.main.async {
                homeViewModel.homeState = nil
            }
        }
        .onReceive(locationTimer) { _ in

            guard let location = locationService.currentLocation else {
                print("❌ currentLocation is nil")
                return
            }

            homeViewModel.updateLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        }
        // HomeScreen stays in the nav stack for as long as the rider is logged in —
        // the same role Android's always-alive MainActivity plays — so it's the
        // one place that should always catch a `block` push, however deep the
        // rider has navigated into the booking flow.
        .onReceive(NotificationManager.shared.$pendingNotification) { payload in

            guard let payload,
                  NotificationManager.shared.customerAction(for: payload) == .accountBlocked else {
                return
            }

            showBlockedAlert = true
        }
        // Chat opened from a tapped notification. Handled here because Home is
        // the one screen alive for as long as the rider is logged in, whatever
        // they have navigated into since.
        .onReceive(NotificationManager.shared.$chatToOpen) { _ in
            openPendingChatIfNeeded()
        }
        .alert("Account Blocked",
               isPresented: $showBlockedAlert) {

            Button("OK", role: .cancel) { }
        } message: {
            Text("Your account has been blocked by the admin.")
        }
        .alert("Logout",
               isPresented: $showLogoutAlert) {
            
            Button("NO", role: .cancel) {
//                viewModel.deleteAccount(id: "\(AuthManager.shared.customerId)", router: router)
//                
//                router.push(.landingPage)
            }
            
            Button("YES", role: .destructive) {
                viewModel.logOut(id: "\(AuthManager.shared.customerId)", router: router)
                
                router.push(.landingPage)
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [
                "Check out this amazing Taxi App 🚖",
                ""
            ])
        }
        .sheet(isPresented: $showPlaceSearch) {
            
            PlaceSearchView { address, coordinate in
                
                if searchType == .pickup {
                    pickupAddress = address
                    currentLat = coordinate.latitude
                    currentLong = coordinate.longitude
                } else {
                    destinationAddress = address
                    destinationLat = coordinate.latitude
                    destinationLong = coordinate.longitude
                }
            }
        }
        .alert("Invalid Location",
               isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
        .overlay(alignment: .leading) {
            
            ZStack(alignment: .leading) {
                
                if presentSideMenu {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                presentSideMenu = false
                            }
                        }
                }
                
                SideMenu(
                    isShowing: $presentSideMenu,
                    content: AnyView(
                        SideMenuView(
                            presentSideMenu: $presentSideMenu
                        ) { selectedRow in
                            handleMenuNavigation(selectedRow)
                        }
                    )
                )
            }
        }
        .overlay(GlobalToastView().environmentObject(toastManager))
    }
}

private extension HomeScreen {

    /// Consumes `chatToOpen` if it's set — from either the live tap arriving
    /// while this screen is already up, or one that landed before this screen
    /// had mounted at all (a cold launch straight from a tapped notification,
    /// where `@Published` has nothing to replay to a subscriber that joins
    /// late). Idempotent: safe to call from both `.onAppear` and `.onReceive`.
    func openPendingChatIfNeeded() {

        guard let bookingId = NotificationManager.shared.chatToOpen,
              !bookingId.isEmpty else {
            return
        }

        NotificationManager.shared.chatToOpen = nil

        router.push(.chat(bookingId: bookingId))
    }
}

private extension HomeScreen {
    
    var bottomSection: some View {
        
        Button {
            validateAndGetCab()
        } label: {
            Text("GET CAB")
                .primaryButtonStyle()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 70)
    }
    
    private func validateAndGetCab() {
        
        let pickup = pickupAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let destination = destinationAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if pickup.isEmpty {
            validationMessage = "Please enter pickup location."
            showValidationAlert = true
            return
        }
        
        if destination.isEmpty {
            validationMessage = "Please enter destination."
            showValidationAlert = true
            return
        }
        
        if pickup == destination {
            validationMessage = "Pickup and destination cannot be the same."
            showValidationAlert = true
            return
        }
                router.push(
                    .bookingPreview(pickupAddress: pickupAddress, destinationAddress: destinationAddress, fromLat: currentLat, fromLong: currentLong, toLat: destinationLat, toLong: destinationLong)
                )
        //homeViewModel.getNearDrivers(latitude: currentLat, longitude: currentLong)
    }
}

private extension HomeScreen {
    
    func handleMenuNavigation(_ menu: SideMenuRowType) {
        
        switch menu {
            
        case .home:
            break
            
        case .history:
            router.push(.history)
            
        case .booking:
            router.push(.booking)
            
        case .emergency:
            router.push(.emergency)
            
        case .setting:
            router.push(.setting)
            
        case .promotion:
            router.push(.promotion)
            
        case .share:
            showShareSheet = true
            
        case .about:
            router.push(.about)
            
        case .help:
            router.push(.help)
            
        case .logout:
            showLogoutAlert = true
        }
    }
}

#Preview {
    HomeScreen()
}
