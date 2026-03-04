//
//  LandingScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 27/02/26.
//

import SwiftUI

struct LandingScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ScrollView {
                
                Image("landingPage")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            .scrollDisabled(true)
        }
        .safeAreaInset(edge: .bottom) {
            bottomSection
        }
        .appNavigationBar(
            title: Bundle.main.appName,
            leading: .none
        )
    }
    
    private var bottomSection: some View {
        
        HStack(spacing: 1) {
            
            Button {
                router.push(.login)
            } label: {
                
                Text("SIGN IN")
                    .font(AppFont.font(.medium, size: 18))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppColors.grayColor)
            }
            
            Button(action: {
                router.push(.registration)
            }) {
                Text("REGISTER")
                    .font(AppFont.font(.medium, size: 18))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppColors.grayColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}

#Preview {
    LandingScreen()
        .environmentObject(AppRouter())
}
