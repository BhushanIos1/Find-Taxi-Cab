//
//  RegisterViewModel.swift
//  Find Taxi Cab Driver
//
//  Created by Bhushan Kumar on 22/03/26.
//

import SwiftUI

enum RegistrationState: Equatable {
    case success(String)
    case failure(String)
}

@MainActor
final class RegisterViewModel: ObservableObject {
    
    @Published var isSuccess: Bool = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var registrationState: RegistrationState?
    
    func register(
        name: String,
        email: String,
        phone: String,
        password: String,
        address: String,
        router: AppRouter
    ) {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        let emailTrimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneTrimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordTrimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task {
            
            defer { isLoading = false }
            
            do {
                
                let fcmToken = FCMTokenManager.shared.getToken() ?? "FIREBASE_FCM_TOKEN"
                
                let response: RegisterResponse = try await APIClient.shared.request(
                    DriverAPI.register(
                        name: name,
                        email: emailTrimmed,
                        phone: phoneTrimmed,
                        password: passwordTrimmed,
                        address: address
                    ),
                    responseType: RegisterResponse.self
                )
                
                if response.result == "success",
                   let id = response.id {
                    
                    print("✅ Registered ID:", id)
                    
                    isSuccess = true
                    
                    AppState.shared.login(
                        driverId: "\(id)",
                        token: fcmToken, status: "free")
                    
                    if !fcmToken.isEmpty {
                        updateFCMToken(driverId: "\(id)", token: fcmToken)
                    }
                    
                    registrationState = .success("Registration Successful")
                    
                } else {
                    let message = response.error ?? "Registration Failed"
                    print("❌ REGISTER FAILED:", message)
                    errorMessage = message
                    registrationState = .failure(message)
                }
                
            } catch {
                print("❌ REGISTER FLOW ERROR:", error.localizedDescription)
                errorMessage = error.localizedDescription
                registrationState = .failure(error.localizedDescription)
            }
        }
    }
    
    private func updateFCMToken(driverId: String, token: String) {

        Task {

            do {

                let response: CommonResponse = try await APIClient.shared.request(DriverAPI.updateFCMToken(token: token),
                    responseType: CommonResponse.self)

                print("✅ FCM TOKEN UPDATED")
                print(response)

            } catch {

                print("❌ FCM TOKEN UPDATE ERROR")
                print(error.localizedDescription)
            }
        }
    }
    
    func forgotPassword(email: String,router: AppRouter) {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        let emailTrimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task {
            
            defer { isLoading = false }
            
            do {
                
                let response: CommonResponse = try await APIClient.shared.request(
                    DriverAPI.forgotPassword(email: emailTrimmed),
                    responseType: CommonResponse.self
                )
                
                if response.result == "success" {
                    
                    let message = response.message ?? "Email sent successfully"
                    
                    print("✅ FORGOT PASSWORD:", message)
                    
                    isSuccess = true
                    registrationState = .success(message)
                    
                } else {
                    
                    let message = response.message ?? "Failed to send email"
                    print("❌ FORGOT PASSWORD FAILED:", message)
                    errorMessage = message
                    registrationState = .failure(message)
                }
                
            } catch {
                print("❌ FORGOT PASSWORD ERROR:", error.localizedDescription)
                errorMessage = error.localizedDescription
                registrationState = .failure(error.localizedDescription)
            }
        }
    }
    
    func logOut(id: String, router: AppRouter) {
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            
            defer { isLoading = false }
            
            do {
                
                let response: RegisterResponse = try await APIClient.shared.request(
                    DriverAPI.logout,
                    responseType: RegisterResponse.self
                )
                
                if response.result == "success" {
                    
                    print("✅ Logout ")
                    
                    isSuccess = true
                    
                    AppState.shared.logout()
                    
                } else {
                    let message = response.error ?? "LOGOUT FAILED"
                    print("❌ LOGOUT FAILED:", message)
                    errorMessage = message
                }
                
            } catch {
                print("❌ LOGOUT FLOW ERROR:", error.localizedDescription)
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct RegisterResponse: Decodable {
    let result: String
    let message: String?
    let id: Int?
    let error: String?
}
