//
//  BookingScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI

struct BookingScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack {
            
            ScrollView(showsIndicators: false) {
                
                VStack(alignment: .leading) {
                    
                    Text("Booking Details")
                        .font(AppFont.font(.medium, size: 18))
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        HStack() {
                            Text("Booking Id :")
                            Text("1494")
                        }
                        
                        HStack() {
                            Text("Driver Mobile :")
                            Text("\("1494334534534")")
                        }
                        
                        HStack(alignment: .top) {
                            Text("Source Address :")
                            Text("\("Back Ln, Cornmill Ln, Liversedge, Heckmondwike WF1...")")
                        }
                        
                        HStack(alignment: .top) {
                            Text("Dest Address :")
                            Text("\("Back Ln, Cornmill Ln, Liversedge, Heckmondwike WF1...")")
                        }
                        
                        HStack() {
                            Text("Booking Date :")
                            Text("\("2019-06-11  23:02:37")")
                        }
                        
                        HStack() {
                            Text("Booking State :")
                            Text("\("abondon")")
                        }
                    }
                    .font(AppFont.font(.regular, size: 14))
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        colorScheme == .dark
                        ? Color(.systemGray6)
                        : Color(.white)
                    )
                    .shadow(
                        color: .black.opacity(0.08),
                        radius: 10,
                        x: 0,
                        y: 4
                    )
                    .padding(.horizontal, 20)
                    
                    Button {
                        router.pop()
                    } label: {
                        Text("CONTINUE")
                            .primaryButtonStyle()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
            }
        }
        .appNavigationBar(
            title: "Booking Page",
            leading: .back) {
                router.pop()
            }
    }
}

#Preview {
    BookingScreen()
}
