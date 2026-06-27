//
//  HomeViewModel.swift
//  Find Taxi Cab Driver
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
    
    @Published var driverStatus: DriverStatus = .free
    
    init() {
        driverStatus = DriverStatus(rawValue: AuthManager.shared.workStatus) ?? .free
    }
    
    // MARK: - Change Driver Status
    
    func syncStatusOnAppear() {
        
        let savedStatus = AuthManager.shared.workStatus
        
        guard !savedStatus.isEmpty else { return }
        
        Task {
            
            do {
                
                let response: CommonResponse =
                try await APIClient.shared.request(
                    DriverAPI.changeStatus(status: savedStatus),
                    responseType: CommonResponse.self
                )
                
                print("✅ STATUS SYNC")
                print(response)
                
            } catch {
                print("❌ STATUS SYNC ERROR")
                print(error)
            }
        }
    }
    
    func changeStatus() {
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        let newStatus: DriverStatus = driverStatus == .free ? .busy : .free
        
        Task {
            
            defer {
                isLoading = false
            }
            
            do {
                
                let response: CommonResponse =
                try await APIClient.shared.request(
                    DriverAPI.changeStatus(
                        status: newStatus.rawValue
                    ),
                    responseType: CommonResponse.self
                )
                
                if response.result == "success" {
                    
                    driverStatus = newStatus
                    
                    AuthManager.shared.workStatus = newStatus.rawValue
                                        
                    homeState = .success(response.message ?? "Status Updated")
                    
                } else {
                    
                    let message = response.message ?? "Failed"
                    errorMessage = message
                    homeState = .failure(message)
                }
                
            } catch {
                
                errorMessage = error.localizedDescription
                homeState = .failure(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Update Driver Location
    
    func updateLocation(latitude: Double, longitude: Double) {
        
        Task {
            
            do {
                
                let response: CommonResponse = try await APIClient.shared.request(
                    DriverAPI.updateLocation(lat: "\(latitude)", lng: "\(longitude)"),
                    responseType: CommonResponse.self)
                
                print("📍 LOCATION UPDATED:", response.result ?? "")
                
            } catch {
                
                print("❌ LOCATION UPDATE ERROR:", error)
            }
        }
    }
    
    // MARK: - Update FCM Token
    
    func updateDriverToken() {
        
        guard let token = FCMTokenManager.shared.getToken(),
              !token.isEmpty else {
            
            print("❌ FCM TOKEN NOT FOUND")
            return
        }
        
        Task {
            
            do {
                
                let response: CommonResponse = try await APIClient.shared.request(
                    DriverAPI.updateFCMToken(token: token),
                    responseType: CommonResponse.self
                )
                
                print("🔥 TOKEN UPDATED:", response.result ?? "")
                
            } catch {
                print("❌ TOKEN UPDATE ERROR:", error)
            }
        }
    }
}
