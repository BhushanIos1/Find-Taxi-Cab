//
//  CustomNavigationBar.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 26/02/26.
//

import SwiftUI

enum NavBarLeadingType {
    case back
    case menu
    case none
}

struct CustomNavigationBar: View {
    
    let title: String
    let leadingType: NavBarLeadingType
    
    var onMenuTap: (() -> Void)?
    
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        
        HStack {
            
            leadingView
            
            Spacer()
            
            Text(title)
                .font(AppFont.font(.medium, size: 20))
                .foregroundStyle(.white)
            
            Spacer()
            
            Color.clear
                .frame(width: 40)
        }
        .frame(height: 58)
        .background(AppColors.primaryYellow)
    }
}

private extension CustomNavigationBar {
    
    @ViewBuilder
    var leadingView: some View {
        
        switch leadingType {
            
        case .back:
            Button {
                router.pop()
            } label: {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
            }
            .frame(width: 56, height: 56)
            .contentShape(Rectangle())
            
        case .menu:
            Button {
                onMenuTap?()
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
            }
            .frame(width: 56, height: 56)
            .contentShape(Rectangle())
            
        case .none:
            Color.clear
                .frame(width: 50)
        }
    }
}
