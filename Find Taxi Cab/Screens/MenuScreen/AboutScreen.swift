//
//  AboutScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI

struct AboutScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    var body: some View {
        
        ZStack {
            
            VStack {
                Spacer()
                Text("About us test data")
                    .font(AppFont.font(.regular, size: 16))
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .appNavigationBar(
            title: "About Us",
            leading: .back) {
                router.pop()
            }
    }
}
