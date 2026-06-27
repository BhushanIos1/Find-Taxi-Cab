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
        .alert("Logout",
               isPresented: $showLogoutAlert) {
            
            Button("NO", role: .cancel) {
                viewModel.deleteAccount(id: "\(AuthManager.shared.customerId)", router: router)
                
                router.push(.landingPage)
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
