//
//  GoogleMapView.swift
//  Google Maps Tutorial
//

import SwiftUI
import GoogleMaps
import CoreLocation

struct GoogleMapView: UIViewRepresentable {
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> GMSMapView {
        
        let mapView = GMSMapView()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.settings.indoorPicker = false
        mapView.settings.tiltGestures = false
        
        context.coordinator.mapView = mapView
        context.coordinator.requestLocation()
        
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {}
}

class Coordinator: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var mapView: GMSMapView?
    
    func requestLocation() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first,
              let mapView = mapView else { return }
        
        let coordinate = location.coordinate
        
        let camera = GMSCameraPosition.camera(
            withLatitude: coordinate.latitude,
            longitude: coordinate.longitude,
            zoom: 16
        )
        
        mapView.animate(to: camera)
        
        // Marker
        let marker = GMSMarker(position: coordinate)
        marker.title = "Your Location"
        //marker.icon = GMSMarker.markerImage(with: .blue)
        marker.icon = UIImage(named: "mapPin")
        marker.map = mapView
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Location error:", error.localizedDescription)
    }
}
