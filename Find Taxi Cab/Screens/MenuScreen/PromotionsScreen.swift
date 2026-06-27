//
//  PromotionsScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct PromotionsScreen: View {
    
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
            title: "Promotions",
            leading: .back) {
                router.pop()
            }
            .onAppear {
                viewModel.getPromotions()
            }
            .overlay(
                GlobalToastView()
                    .environmentObject(toastManager)
            )
    }
}
