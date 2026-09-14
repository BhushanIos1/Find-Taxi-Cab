//
//  DirectionsService.swift
//  Find Taxi Cab
//
//  Created by Claude on 12/09/26.
//

import CoreLocation
import GoogleMaps

struct RouteInfo {

    /// Decoded overview polyline, ready to hand to a `GMSPolyline`.
    let path: GMSPath

    let distanceText: String
    let durationText: String
}

/// Stateless wrapper over the Directions API — the rider-side twin of the
/// driver app's service of the same name.
enum DirectionsService {

    static func fetchRoute(
        origin: CLLocationCoordinate2D,
        destination: CLLocationCoordinate2D
    ) async throws -> RouteInfo {

        var components = URLComponents(
            string: "https://maps.googleapis.com/maps/api/directions/json"
        )!

        components.queryItems = [
            .init(name: "origin", value: "\(origin.latitude),\(origin.longitude)"),
            .init(name: "destination", value: "\(destination.latitude),\(destination.longitude)"),
            .init(name: "mode", value: "driving"),
            .init(name: "key", value: MapAPIKey.directionApiKey)
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let decoded = try JSONDecoder().decode(DirectionsResponse.self, from: data)

        guard let route = decoded.routes.first,
              let leg = route.legs.first,
              let path = GMSPath(fromEncodedPath: route.overviewPolyline.points) else {
            throw URLError(.cannotParseResponse)
        }

        return RouteInfo(
            path: path,
            distanceText: leg.distance.text,
            durationText: leg.duration.text
        )
    }
}
