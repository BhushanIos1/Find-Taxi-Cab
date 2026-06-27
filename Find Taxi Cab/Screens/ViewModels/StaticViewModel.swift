//
//  StaticViewModel.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 22/06/26.
//

import Foundation

enum StaticState: Equatable {
    case success(String)
    case failure(String)
}

@MainActor
final class StaticViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var content: String = ""
    @Published var state: StaticState?
    
    func getAboutUs() {
        
        loadContent(api: .aboutUs)
    }
    
    func getPromotions() {
        
        loadContent(api: .promotions)
    }
    
    func getHelp() {
        
        loadContent(api: .help)
    }
}

private extension StaticViewModel {
    
    func loadContent(api: CustomerAPI) {
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            
            defer { isLoading = false }
            
            do {
                
                let response: StaticContentResponse =
                try await APIClient.shared.request(
                    api,
                    responseType: StaticContentResponse.self
                )
                
                if response.result.lowercased() == "success" {
                    
                    content = response.data ?? ""
                    
                    state = .success(response.data ?? "Data Loaded")
                    
                } else {
                    
                    let message = "Failed To Load Data"
                    
                    errorMessage = message
                    state = .failure(message)
                }
                
            } catch {
                
                print("❌ STATIC API ERROR")
                print(error)
                
                errorMessage = error.localizedDescription
                state = .failure(error.localizedDescription)
            }
        }
    }
}

struct StaticContentResponse: Decodable {
    
    let result: String
    let data: String?
}
