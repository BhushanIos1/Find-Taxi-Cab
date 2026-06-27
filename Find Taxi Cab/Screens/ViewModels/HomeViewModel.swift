//
//  HomeViewModel.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 18/06/26.
//

import Foundation

enum HomeState: Equatable {
    case success(String)
    case failure(String)
}

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var homeState: HomeState?
    
    @Published var nearbyDrivers: [NearDriver] = []
    
    // MARK: - Update Customer Location
    
    func updateLocation(latitude: Double, longitude: Double) {
        
        Task {
            
            do {
                
                let response: CommonResponse = try await APIClient.shared.request(
                    CustomerAPI.updateLocation(lat: "\(latitude)", lng: "\(longitude)"),
                    responseType: CommonResponse.self)
                
                print("📍 LOCATION UPDATED:", response.result ?? "")
                
            } catch {
                
                print("❌ LOCATION UPDATE ERROR:", error)
            }
        }
    }
    
    func getNearDrivers(latitude: Double, longitude: Double) {
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            
            defer { isLoading = false }
            
            do {
                
                let response: NearDriversResponse = try await APIClient.shared.request(
                    CustomerAPI.getNearDrivers(
                        lat: "\(latitude)",
                        lng: "\(longitude)"
                    ),
                    responseType: NearDriversResponse.self
                )
                
                if response.success == 1 {
                    
                    nearbyDrivers = response.driverData ?? []
                    
                    print("✅ NEAR DRIVERS FOUND")
                    print("COUNT:", nearbyDrivers.count)
                    
                    isLoading = false
                    homeState = .success("")
                    
                } else {
                    
                    nearbyDrivers = []
                    
                    let message = response.error ?? "❌ NO DRIVERS"
                    print(response.error ?? "")
                    
                    errorMessage = message
                    homeState = .failure(message)
                }
                
            } catch {
                
                print("❌ GET NEAR DRIVERS ERROR")
                print(error)
                
                errorMessage = error.localizedDescription
                homeState = .failure(error.localizedDescription)
            }
        }
    }
}

struct NearDriversResponse: Decodable {
    
    let success: Int
    let driverData: [NearDriver]?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case driverData = "driver_data"
        case error
    }
}

struct NearDriver: Decodable, Identifiable {
    
    let id: String
    
    let driverName: String?
    let driverPhoto: String?
    let driverLat: String?
    let driverLng: String?
    let vehicleNo: String?
    let vehicleMake: String?
    let vehicleModel: String?
    let vehicleSeater: String?
    let workStatus: String?
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case driverName
        case driverPhoto = "driver_photo"
        case driverLat = "driver_lat"
        case driverLng = "driver_lng"
        case vehicleNo = "vehicle_no"
        case vehicleMake = "vehicle_make"
        case vehicleModel = "vehicle_model"
        case vehicleSeater = "vehicle_seater"
        case workStatus = "work_status"
    }
}
