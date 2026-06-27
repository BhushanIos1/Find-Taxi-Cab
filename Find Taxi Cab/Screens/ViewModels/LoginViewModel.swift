//
//  LoginViewModel.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 12/04/26.
//

import SwiftUI

enum LoginState: Equatable {
    case success(String)
    case failure(String)
}

@MainActor
final class LoginViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var loginState: LoginState?
    
    private var isRequestInProgress = false
    
    @Published var errorMessage: String?
    @Published var userData: Customer?
    
    func login(email: String, password: String, router: AppRouter) {
        
        guard !isRequestInProgress else {
            print("⛔️ Request already in progress")
            return
        }
        
        isRequestInProgress = true
        isLoading = true
        
        // ✅ Trim inputs
        let emailTrimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordTrimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task {
            
            defer {
                isLoading = false
                isRequestInProgress = false
            }
            
            do {
                
                let fcmToken = FCMTokenManager.shared.getToken() ?? "FIREBASE_FCM_TOKEN"
                
                let response: LoginResponse = try await APIClient.shared.request(
                    CustomerAPI.login(
                        email: emailTrimmed,
                        password: passwordTrimmed,
                        token: fcmToken
                    ),
                    responseType: LoginResponse.self
                )
                
                if response.result == "success", let customer = response.customerData {
                    
                    print("✅ LOGIN SUCCESS:", customer.custId)
                    AppState.shared.login(customerId: customer.custId, token: customer.token, customerName: customer.custName, email: customer.email)
                    
                    
                    if !fcmToken.isEmpty {
                        updateFCMToken(customerId: customer.custId, token: fcmToken)
                    }
                    
                    loginState = .success("Login Successful")
                    
                } else {
                    
                    let message = response.message ?? "Invalid login response"
                    print("❌ LOGIN FAILED:", message)
                    
                    loginState = .failure(message)
                }
            } catch {
                print("❌ LOGIN ERROR:", error.localizedDescription)
                loginState = .failure(error.localizedDescription)
            }
        }
    }
    
    private func updateFCMToken(customerId: String, token: String) {
        
        Task {
            
            do {
                
                let response: CommonResponse = try await APIClient.shared.request(CustomerAPI.updateFCMToken(token: token), responseType: CommonResponse.self)
                
                print("✅ FCM TOKEN UPDATED")
                print(response)
                
            } catch {
                
                print("❌ FCM TOKEN UPDATE ERROR")
                print(error.localizedDescription)
            }
        }
    }
    
    func changePassword(password: String, router: AppRouter) {
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        let passwordTrimmed = password.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        Task {
            
            defer { isLoading = false }
            
            do {
                
                let response: CommonResponse = try await APIClient.shared.request(
                    CustomerAPI.changePassword(password: passwordTrimmed),
                    responseType: CommonResponse.self
                )
                
                if response.result == "success" {
                    
                    let message = response.message ?? "Password changed successfully"
                    
                    print("✅ CHANGE PASSWORD:", message)
                    
                    isLoading = false
                    loginState = .success(message)
                    
                } else {
                    
                    let message = response.message ?? "Failed to change password"
                    
                    print("❌ CHANGE PASSWORD FAILED:", message)
                    
                    errorMessage = message
                    loginState = .failure(message)
                }
                
            } catch {
                
                print("❌ CHANGE PASSWORD ERROR:", error.localizedDescription)
                
                errorMessage = error.localizedDescription
                loginState = .failure(error.localizedDescription)
            }
        }
    }
    
    func updateCardDetails(
        cardNumber: String,
        cardHolder: String,
        month: String,
        year: String
    ) {
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            
            defer { isLoading = false }
            
            do {
                
                let response = try await APIClient.shared.updateCardDetails(
                    cardNumber: cardNumber,
                    cardHolder: cardHolder,
                    month: month,
                    year: year
                )
                
                if response.result?.lowercased() == "success" {
                    
                    isLoading = false
                    let message = response.message ?? "Card Updated"
                    loginState = .success(message)
                    
                } else {
                    
                    let message = response.message ?? "Failed To Update Card"
                    errorMessage = message
                    loginState = .failure(message)
                }
                
            } catch {
                
                print("❌ UPDATE CARD ERROR")
                print(error)
                
                errorMessage = error.localizedDescription
                loginState = .failure(error.localizedDescription)
            }
        }
    }
}
