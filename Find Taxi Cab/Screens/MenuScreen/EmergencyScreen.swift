//
//  EmergencyScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI

struct EmergencyScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    var body: some View {
        
        ZStack {
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 50) {
                    
                    Spacer(minLength: 10)
                    
                    Button {
                        PhoneHelper.call("01132772299")
                    } label: {
                        Image("emergencyCall")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                    }
                    
                    VStack(spacing: 15) {
                        Text("01132772299")
                            .font(AppFont.font(.semiBold, size: 30))
                        
                        Text("Tap above phone number for emergency call")
                            .font(AppFont.font(.regular, size: 16))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(20)
            }
        }
        .appNavigationBar(
            title: "Emergency",
            leading: .back) {
                router.pop()
            }
    }
}

#Preview {
    EmergencyScreen()
}
