//
//  HomeScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 28/02/26.
//

import SwiftUI

struct HomeScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @State private var presentSideMenu = false
    
    @State private var showShareSheet = false
    @State private var showLogoutAlert = false
    
    @StateObject
    private var locationService = LocationService()
    
    @State private var pickupAddress = ""
    @State private var destinationAddress = ""
    
    @State private var showPlaceSearch = false
    @State private var searchType: SearchType = .pickup
    
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    
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
        }
        .onReceive(locationService.$currentAddress) { address in
            pickupAddress = address
        }
        .alert("Logout",
               isPresented: $showLogoutAlert) {
            
            Button("NO", role: .cancel) { }
            
            Button("YES", role: .destructive) {
                //performLogout()
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
                } else {
                    destinationAddress = address
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
            .bookingPreview(
                pickupAddress: pickup,
                destinationAddress: destination
            )
        )
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
