//
//  NetworkLogger.swift
//  Find Taxi Cab Driver
//
//  Created by Bhushan Kumar on 21/03/26.
//

import Foundation

final class NetworkLogger {
    
    static let shared = NetworkLogger()
    private init() {}
    
    // MARK: - REQUEST LOG
    func logRequest(
        url: String,
        method: String,
        parameters: [String: Any]?
    ) {
        print("\n🚀 REQUEST ------------------------------")
        print("URL:", url)
        print("METHOD:", method)
        
        if let params = parameters {
            print("\nPARAMETERS:")
            print(prettyPrint(params))
        }
        
        if let params = parameters {
            let query = params.map { "\($0.key)=\($0.value)" }
                .joined(separator: "&")
            print("\nFULL URL:")
            print("\(url)?\(query)")
        }
        
        print("----------------------------------------\n")
    }
    
    // MARK: - RESPONSE LOG
    func logResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) {
        print("\n📥 RESPONSE -----------------------------")
        
        if let http = response as? HTTPURLResponse {
            print("STATUS:", http.statusCode)
        }
        
        if let data = data, !data.isEmpty {
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                print("\nJSON:")
                print(prettyPrint(json))
            } catch {
                let raw = String(data: data, encoding: .utf8) ?? "nil"
                print("\nRAW:", raw)
            }
        } else {
            print("EMPTY RESPONSE ❌")
        }
        
        if let error = error {
            print("\n❌ ERROR:", error.localizedDescription)
        }
        
        print("----------------------------------------\n")
    }
    
    // MARK: - PRETTY PRINT
    private func prettyPrint(_ object: Any) -> String {
        guard let data = try? JSONSerialization.data(
            withJSONObject: object,
            options: .prettyPrinted
        ),
        let string = String(data: data, encoding: .utf8)
        else { return "\(object)" }
        
        return string
    }
}
