//
//  SideMenu.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI

struct SideMenu: View {

    @Binding var isShowing: Bool
    var content: AnyView

    var body: some View {

        ZStack(alignment: .leading) {

            Color.black
                .opacity(isShowing ? 0.3 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        isShowing = false
                    }
                }
                .allowsHitTesting(isShowing)

            content
                .offset(x: isShowing ? 0 : -300)
        }
        .animation(.easeInOut(duration: 0.25), value: isShowing)
    }
}
