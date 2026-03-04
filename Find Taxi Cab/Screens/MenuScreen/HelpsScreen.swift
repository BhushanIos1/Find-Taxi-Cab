//
//  HelpSCreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI

struct HelpsScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    var body: some View {
        
        ZStack {
            
            ScrollView(showsIndicators: false) {
                
                VStack {
                    
                    Text("Office Address:")
                        .font(AppFont.font(.medium, size: 20))
                    
                    Text("Sugar Mills, Sugar Refinery\nSuite 29.5, Oakhurst Avenue,\nBeeston, Leeds\nLS11 7HL\n\nContact: 01132772299\n\ninfo@findtaxicab.com")
                        .font(AppFont.font(.regular, size: 16))
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(uiColor: .systemBackground))
                )
                .shadow(
                    color: .black.opacity(0.08),
                    radius: 10,
                    x: 0,
                    y: 4
                )
                .padding(20)
            }
        }
        .appNavigationBar(
            title: "Help",
            leading: .back) {
                router.pop()
            }
    }
}

#Preview {
    HelpsScreen()
}
