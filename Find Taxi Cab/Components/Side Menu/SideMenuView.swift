//
//  SideMenu.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 28/02/26.
//

import SwiftUI

struct SideMenuView: View {
    
    @Binding var presentSideMenu: Bool
    var onMenuSelected: (SideMenuRowType) -> Void
    
    @State private var selectedRow: SideMenuRowType = .home
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            profileImageView
            
            // ✅ SCROLLABLE MENU
            ScrollView(showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 5) {
                    
                    ForEach(SideMenuRowType.allCases,
                            id: \.self) { row in
                        
                        rowView(
                            isSelected: selectedRow == row,
                            imageName: row.iconName,
                            title: row.title
                        ) {
                            
                            selectedRow = row
                            presentSideMenu = false
                            
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 0.25
                            ) {
                                onMenuSelected(row)
                            }
                        }
                    }
                    Spacer(minLength: 30)
                }
                .padding(.top, 20)
            }
        }
        .frame(width: 280)
        .background(Color(UIColor.systemBackground))
    }
}

private extension SideMenuView {
    
    var profileImageView: some View {
        
        VStack(spacing: 15) {
            
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 92, height: 92)
            
            VStack(spacing: 5) {
                
                Text("Welcome")
                    .font(AppFont.font(.medium, size: 20))
                    .foregroundColor(.white)
                
                Text(AuthManager.shared.customerName)
                    .font(AppFont.font(.regular, size: 16))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(AppColors.primaryYellow)
    }
}

private extension SideMenuView {
    
    func rowView(
        isSelected: Bool,
        imageName: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        
        Button(action: action) {
            
            HStack(spacing: 15) {
                
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 22, height: 22)
                
                Text(title)
                    .font(AppFont.font(.regular, size: 20))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    SideMenuView(presentSideMenu: .constant(true), onMenuSelected: { _ in
        print("")
    })
}
