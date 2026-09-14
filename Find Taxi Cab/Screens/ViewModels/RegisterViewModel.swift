//
//  RegisterViewModel.swift
//  Find Taxi Cab
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
    
    /// Takes the whole Android registration form. The card fields in particular
    /// are what `get_card_details` reads back later — if they never leave the
    /// device, the customer logs in with no card on file and cannot pay.
    func register(
        name: String,
        email: String,
        phone: String,
        password: String,
        address: String,
        postalCode: String,
        cardHolderName: String,
        cardNumber: String,
        cardMonth: String,
        cardYear: String,
        router: AppRouter
    ) {
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        func trimmed(_ value: String) -> String {
            value.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        Task {
            
            defer { isLoading = false }
            
            do {
                
                let response: RegisterResponse =
                try await APIClient.shared.request(
                    CustomerAPI.register(
                        name: trimmed(name),
                        email: trimmed(email),
                        phone: trimmed(phone),
                        password: trimmed(password),
                        address: trimmed(address),
                        postalCode: trimmed(postalCode),
                        cardHolderName: trimmed(cardHolderName),
                        cardNumber: trimmed(cardNumber),
                        cardMonth: trimmed(cardMonth),
                        cardYear: trimmed(cardYear),
                        profilePhoto: nil
                    ),
                    responseType: RegisterResponse.self
                )
                
                if response.result == "success",
                   let custId = response.custid {
                    
                    print("✅ CUSTOMER REGISTERED:", custId)
                    
                    isSuccess = true

                    registrationState = .success(response.message ?? "Registration Successful")
                    
                } else {
                    
                    let message = response.message ?? "Registration Failed"
                    
                    print("❌ CUSTOMER REGISTER FAILED:", message)
                    
                    errorMessage = message
                    registrationState = .failure(message)
                }
                
            } catch {
                
                print("❌ CUSTOMER REGISTER ERROR:", error.localizedDescription)
                
                errorMessage = error.localizedDescription
                registrationState = .failure(error.localizedDescription)
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
                    CustomerAPI.forgotPassword(email: emailTrimmed),
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
    
    func deleteAccount(id: String, router: AppRouter) {
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            
            defer { isLoading = false }
            
            do {
                
                let response: RegisterResponse = try await APIClient.shared.request(
                    CustomerAPI.deleteCustomer,
                    responseType: RegisterResponse.self)
                
                if response.result == "success" {
                    
                    print("✅ Deleted ")
                    
                    isSuccess = true
                    
                    AppState.shared.logout()
                    
                } else {
                    let message = response.message ?? "Deletion FAILED"
                    print("❌ Deletion FAILED:", message)
                    errorMessage = message
                }
                
            } catch {
                print("❌ Deletion FLOW ERROR:", error.localizedDescription)
                errorMessage = error.localizedDescription
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
                    CustomerAPI.logout,
                    responseType: RegisterResponse.self)
                
                if response.result == "success" {
                    
                    print("✅ Logout ")
                    
                    isSuccess = true
                    
                    AppState.shared.logout()
                    
                } else {
                    let message = response.message ?? "LOGOUT FAILED"
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
    let custid: Int?
}
