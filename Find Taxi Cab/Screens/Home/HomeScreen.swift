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
    
    @StateObject
    private var locationManager = LocationManager()
    
    @State private var showShareSheet = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .ignoresSafeArea()
            
            homeContentView
        }
        .safeAreaInset(edge: .bottom) {
            bottomSection
        }
        .appNavigationBar(
            title: "Home",
            leading: .menu
        ) {
            withAnimation(.easeInOut) {
                presentSideMenu.toggle()
            }
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
        .overlay(alignment: .leading) {
            
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

/*
 if #available(iOS 17.0, *) {
 Map(
 position: .constant(
 .region(locationManager.region)
 )
 ) {
 if let coordinate = locationManager.userLocation {
 Marker("You are here", coordinate: coordinate)
 }
 }
 .mapControls {
 MapUserLocationButton()
 MapCompass()
 MapScaleView()
 }
 .ignoresSafeArea()
 } else {
 // Fallback on earlier versions
 }
 */

private extension HomeScreen {
    
    var homeContentView: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 0) {
                
                Image("loginLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .padding(.top, 120)
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 40)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
        }
    }
}

private extension HomeScreen {
    
    var bottomSection: some View {
        
        Button {
            validateAndLogin()
        } label: {
            Text("GET CAB")
                .primaryButtonStyle()
        }
        .padding(25)
    }
    
    private func validateAndLogin() {
        
        //        emailError = email.isEmpty
        //        ? "Email required"
        //        : (!ValidationHelper.isValidEmail(email)
        //           ? "Invalid email"
        //           : nil)
        //
        //        passwordError = password.isEmpty
        //        ? "Password required"
        //        : nil
        //
        //        guard emailError == nil,
        //              passwordError == nil else { return }
        
        print("✅ Login Success")
        router.push(.home)
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
