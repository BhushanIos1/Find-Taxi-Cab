//
//  PlaceSearchView.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 08/03/26.
//

import SwiftUI
import GooglePlaces

struct PlaceSearchView: UIViewControllerRepresentable {
    
    var onPlaceSelected: (String, CLLocationCoordinate2D) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> GMSAutocompleteViewController {
        
        let controller = GMSAutocompleteViewController()
        controller.delegate = context.coordinator
        
        // Optional: restrict results to addresses
        let filter = GMSAutocompleteFilter()
        filter.types = ["address"]
        controller.autocompleteFilter = filter
        
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: GMSAutocompleteViewController,
        context: Context
    ) {}
    
    class Coordinator: NSObject, GMSAutocompleteViewControllerDelegate {
        
        let parent: PlaceSearchView
        
        init(_ parent: PlaceSearchView) {
            self.parent = parent
        }
        
        func viewController(
            _ viewController: GMSAutocompleteViewController,
            didAutocompleteWith place: GMSPlace
        ) {
            
            let address = place.formattedAddress ?? ""
            let coordinate = place.coordinate
            
            parent.onPlaceSelected(address, coordinate)
            parent.dismiss()
        }
        
        func viewController(
            _ viewController: GMSAutocompleteViewController,
            didFailAutocompleteWithError error: Error
        ) {
            print("Autocomplete error:", error.localizedDescription)
        }
        
        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            parent.dismiss()
        }
    }
}
