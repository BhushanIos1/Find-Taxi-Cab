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

        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.settings.indoorPicker = false
        mapView.settings.tiltGestures = false

        context.coordinator.mapView = mapView
        context.coordinator.requestLocation()

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

    /// The camera should follow the first fix only — after that the user is free
    /// to pan without being yanked back on the next update.
    private var hasCenteredOnUser = false
    
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
        
        if !hasCenteredOnUser {
            
            hasCenteredOnUser = true
            
            mapView.animate(
                to: GMSCameraPosition.camera(
                    withLatitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    zoom: 16
                )
            )
        }
        
        if let userMarker {
            userMarker.position = coordinate
            return
        }
        
        let marker = GMSMarker(position: coordinate)
        marker.title = "Your Location"
        marker.icon = MapMarkerIcon.userLocation
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.map = mapView
        
        userMarker = marker
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Location error:", error.localizedDescription)
    }
}
