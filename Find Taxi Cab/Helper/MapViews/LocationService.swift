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
    
    @Published var currentLocation: CLLocation?
    @Published var currentAddress: String = ""
    
    override init() {
        super.init()
        
        setupLocationManager()
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
}

// MARK: - Setup

private extension LocationService {
    
    func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Update only after moving 10 meters
        locationManager.distanceFilter = 10
    }
}

extension LocationService {
    
    func startTracking() {
        
        let status = locationManager.authorizationStatus
        
        switch status {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse,
                .authorizedAlways:
            
            locationManager.startUpdatingLocation()
            
        default:
            break
        }
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    func requestCurrentLocation() {
        locationManager.requestLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        
        switch manager.authorizationStatus {
            
        case .authorizedWhenInUse,
                .authorizedAlways:
            
            manager.startUpdatingLocation()
            
        default:
            break
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {

        guard let location = locations.first else { return }

        DispatchQueue.main.async {
            self.currentLocation = location
        }

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

extension LocationService {
    
    func fetchAddress(from location: CLLocation) {
        
        geocoder.reverseGeocodeLocation(location) {
            [weak self] placemarks,
            error in
            
            guard let placemark =
                    placemarks?.first else {
                return
            }
            
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
}
