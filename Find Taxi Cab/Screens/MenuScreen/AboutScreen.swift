//
//  AboutScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct AboutScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @EnvironmentObject
    private var toastManager: ToastManager
    
    @StateObject
    private var viewModel = StaticViewModel()
    
    var body: some View {
        
        ZStack {
            
            VStack {
                Spacer()
                Text(viewModel.content)
                    .font(AppFont.font(.regular, size: 16))
                    .foregroundStyle(.secondary)
                Spacer()
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
            title: "About Us",
            leading: .back) {
                router.pop()
            }
            .onAppear {
                viewModel.getAboutUs()
            }
            .overlay(
                GlobalToastView()
                    .environmentObject(toastManager)
            )
    }
}
