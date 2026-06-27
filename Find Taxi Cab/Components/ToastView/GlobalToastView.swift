//
//  GlobalToastView.swift
//  Find Taxi Cab Driver
//
//  Created by Bhushan Kumar on 08/04/26.
//

import SwiftUI

struct GlobalToastView: View {
    
    @EnvironmentObject var toastManager: ToastManager
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            VStack {
                
                if toastManager.isPresented {
                    ToastView(toastType: toastManager.toastType,
                              title: toastManager.title,
                              subtitle: toastManager.subtitle,
                              onUndo: { toastManager.isPresented = false })
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding()
                }
                Spacer()
            }
        }
        .animation(.easeInOut, value: toastManager.isPresented)
    }
}
