//
//  ShareSheet.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 01/03/26.
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    
    var items: [Any]
    
    func makeUIViewController(context: Context)
    -> UIActivityViewController {
        
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }
    
    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) { }
}
