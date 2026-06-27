//
//  ToastManager.swift
//  Find Taxi Cab Driver
//
//  Created by Bhushan Kumar on 08/04/26.
//

import SwiftUI

class ToastManager: ObservableObject {
    
    @Published var isPresented: Bool = false
    @Published var toastType: ToastType = .info
    @Published var title: String = ""
    @Published var subtitle: String? = nil
    
    func showToast(type: ToastType, title: String, subtitle: String? = nil) {
        self.toastType = type
        self.title = title
        self.subtitle = subtitle
        self.isPresented = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isPresented = false
        }
    }
}
