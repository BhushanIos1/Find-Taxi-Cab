//
//  PromotionsScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI

struct PromotionsScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    var body: some View {
        
        ZStack {
            
            VStack {
                Spacer()
                Text("No promotions available")
                    .font(AppFont.font(.regular, size: 16))
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .appNavigationBar(
            title: "Promotions",
            leading: .back) {
                router.pop()
            }
    }
}
