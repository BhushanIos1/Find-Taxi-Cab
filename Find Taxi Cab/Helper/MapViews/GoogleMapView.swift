//
//  GoogleMapView.swift
//  Google Maps Tutorial
//

import SwiftUI
import GoogleMaps
import CoreLocation

struct GoogleMapView: UIViewRepresentable {

    /// Hands the underlying `GMSMapView` back to the caller so a screen-owned view
    /// model (e.g. `TrackingViewModel`) can place/move its own markers on it.
    var onMapReady: ((GMSMapView) -> Void)? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> GMSMapView {

        let mapView = GMSMapView()

        // MARK: Google Location UI

        // Disable Google's default blue location dot
        mapView.isMyLocationEnabled = false
        mapView.settings.myLocationButton = false

        // Map settings
        mapView.settings.compassButton = true
        mapView.settings.indoorPicker = false
        mapView.settings.tiltGestures = false

        // Assign map to coordinator
        context.coordinator.mapView = mapView

        // Start live location tracking
        context.coordinator.startLocationUpdates()

        // Notify parent
        onMapReady?(mapView)

        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {}
}

class Coordinator: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var mapView: GMSMapView?

    /// Held so each location update *moves* the pin. This used to build a new
    /// `GMSMarker` every time the delegate fired, so a screen left open long
    /// enough accumulated a trail of pins that were never released.
    private var userMarker: GMSMarker?

    private let geocoder = CLGeocoder()
    
    private var lastGeocodedLocation: CLLocation?
    
    // MARK: Camera
    
    private var hasInitialCameraPosition = false
    
    func startLocationUpdates() {
        
        locationManager.delegate = self
        
        // Best available accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Update approximately every 5 meters
        locationManager.distanceFilter = 5
        
        // Ask for permission
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Authorization
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            
        case .authorizedWhenInUse,
                .authorizedAlways:
            
            print("✅ Location permission granted")
            
            locationManager.startUpdatingLocation()
            
        case .denied:
            
            print("❌ Location permission denied")
            
            
        case .restricted:
            
            print("❌ Location permission restricted")
            
        case .notDetermined:
            
            print("⏳ Location permission not determined")
            
        @unknown default:
            
            print("⚠️ Unknown location authorization status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {
            return
        }
        
        // Ignore invalid GPS readings
        guard location.horizontalAccuracy >= 0 else {
            return
        }
        
        let coordinate = location.coordinate
        
        // Update user marker
        updateUserMarker(at: location)
        
        if !hasInitialCameraPosition {
            
            let camera = GMSCameraPosition.camera(
                withLatitude: coordinate.latitude,
                longitude: coordinate.longitude,
                zoom: 16
            )
            
            mapView?.animate(to: camera)
            
            hasInitialCameraPosition = true
        }
    }
    
    private func updateUserMarker(at location: CLLocation) {
        
        guard let mapView = mapView else {
            return
        }
        
        let coordinate = location.coordinate
        
        
        // MARK: Existing Marker
        
        if let marker = userMarker {
            
            // Smooth marker movement
            CATransaction.begin()
            
            CATransaction.setAnimationDuration(0.5)
            
            marker.position = coordinate
            
            CATransaction.commit()
        }
        
        // MARK: Create Marker
        
        else {
            
            let marker = GMSMarker(position: coordinate)
            
            // Temporary title
            marker.title = "Loading location..."
            
            // Custom taxi icon
            marker.icon = UIImage(named: "mapPin")
            
            // Position icon correctly on coordinate
            marker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
            
            // Add to map
            marker.map = mapView
            
            // Store marker
            userMarker = marker
        }
        
        // Update address when required
        updateAddressIfNeeded(for: location)
    }
    
    // MARK: - Reverse Geocoding
    
    private func updateAddressIfNeeded(for location: CLLocation) {
        
        if let lastLocation = lastGeocodedLocation {
            
            let distance = location.distance(
                from: lastLocation
            )
            
            guard distance >= 50 else {
                return
            }
        }
        
        // Remember location we are geocoding
        lastGeocodedLocation = location
        
        // Cancel previous geocoding request
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(
            location
        ) { [weak self] placemarks, error in
            
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                
                guard let marker = self.userMarker else {
                    return
                }
                
                
                // MARK: Geocoding Error
                
                if let error = error {
                    
                    print(
                        "❌ Reverse geocoding error:",
                        error.localizedDescription
                    )
                    
                    marker.title = String(
                        format: "%.6f, %.6f",
                        location.coordinate.latitude,
                        location.coordinate.longitude
                    )
                    
                    return
                }
                
                // MARK: No Address
                
                guard let placemark = placemarks?.first else {
                    
                    marker.title = String(
                        format: "%.6f, %.6f",
                        location.coordinate.latitude,
                        location.coordinate.longitude
                    )
                    
                    return
                }
                
                
                // MARK: Address
                
                let address = self.formattedAddress(
                    from: placemark
                )
                
                marker.title = address.isEmpty
                ? "Current Location"
                : address
                
                print(
                    "📍 Marker Address:",
                    marker.title ?? ""
                )
            }
        }
    }
    
    // MARK: - Format Address
    
    private func formattedAddress(from placemark: CLPlacemark) -> String {
        
        var components: [String] = []
        
        
        if let name = placemark.name,
           !name.isEmpty {
            
            components.append(name)
        }
        
        
        if let locality = placemark.locality,
           !locality.isEmpty {
            
            components.append(locality)
        }
        
        
        if let administrativeArea =
            placemark.administrativeArea,
           !administrativeArea.isEmpty {
            
            components.append(
                administrativeArea
            )
        }
        
        
        return components.joined(
            separator: ", "
        )
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print(
            "❌ Location error:",
            error.localizedDescription
        )
    }
    
    
    // MARK: - Cleanup
    
    deinit {
        
        locationManager.stopUpdatingLocation()
        
        geocoder.cancelGeocode()
        
        userMarker?.map = nil
        
        print("🧹 GoogleMapView Coordinator deallocated")
    }
}
