//
//  LocationService.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 08/03/26.
//

import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject {
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var currentAddress: String = ""
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else { return }
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            
            guard let placemark = placemarks?.first else { return }
            
            let address = [
                placemark.name,
                placemark.locality,
                placemark.administrativeArea
            ]
                .compactMap { $0 }
                .joined(separator: ", ")
            
            DispatchQueue.main.async {
                self?.currentAddress = address
            }
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Location error:", error.localizedDescription)
    }
}
