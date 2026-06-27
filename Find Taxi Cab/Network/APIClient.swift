//
//  APIClient.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 21/03/26.
//

import Alamofire

final class APIClient {
    
    static let shared = APIClient()
    
    private let session: Session
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        
        session = Session(
            configuration: config,
            interceptor: NetworkInterceptor.shared
        )
    }
}

extension APIClient {
    
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T {
        
        let url = endpoint.baseURL + endpoint.path
        
        let request = session.request(
            url,
            method: .post,
            parameters: endpoint.parameters,
            encoding: endpoint.encoding
        )
        
        // ✅ Log request
        NetworkLogger.shared.logRequest(
            url: url,
            method: "POST",
            parameters: endpoint.parameters
        )
        
        let response = await request.serializingData().response
        
        // ✅ Log response
        NetworkLogger.shared.logResponse(
            data: response.data,
            response: response.response,
            error: response.error
        )
        
        // ✅ HANDLE SERVER STATUS FIRST (VERY IMPORTANT)
        if let statusCode = response.response?.statusCode,
           !(200...299).contains(statusCode) {
            
            throw NetworkError.serverMessage("Server error: \(statusCode)")
        }
        
        // ✅ HANDLE EMPTY RESPONSE (YOUR CURRENT ISSUE)
        guard let data = response.data, !data.isEmpty else {
            throw NetworkError.serverMessage("Empty response from server")
        }
        
        do {
            // ✅ First try standard wrapper
            if let decoded = try? JSONDecoder().decode(APIResponse<T>.self, from: data) {
                
                if decoded.isSuccess {
                    
                    if let data = decoded.data {
                        return data
                    }
                    
                    if T.self == EmptyResponse.self {
                        return EmptyResponse() as! T
                    }
                }
            }
            
            // ✅ SECOND: Try direct decoding (YOUR CASE)
            let direct = try JSONDecoder().decode(T.self, from: data)
            return direct
            
        } catch {
            print("❌ DECODING ERROR:", error)
            throw NetworkError.decodingError
        }
    }
}

extension APIClient {
    
    func updateCardDetails(
        cardNumber: String,
        cardHolder: String,
        month: String,
        year: String
    ) async throws -> CommonResponse {
        
        let url = "http://view.findtaxicab.com/admin/api/edit_card_detaile"
        
        print("""
        ==============================
        💳 UPDATE CARD REQUEST
        ==============================
        URL: \(url)
        
        custid: \(AuthManager.shared.customerId)
        card_number: \(cardNumber)
        cardholder: \(cardHolder)
        month: \(month)
        year: \(year)
        ==============================
        """)
        
        return try await withCheckedThrowingContinuation { continuation in
            
            session.upload(
                multipartFormData: { multipart in
                    
                    multipart.append(
                        Data(AuthManager.shared.customerId.utf8),
                        withName: "custid"
                    )
                    
                    multipart.append(
                        Data(cardNumber.utf8),
                        withName: "card_number"
                    )
                    
                    multipart.append(
                        Data(cardHolder.utf8),
                        withName: "card_holder_name"
                    )
                    
                    multipart.append(
                        Data(month.utf8),
                        withName: "card_month"
                    )
                    
                    multipart.append(
                        Data(year.utf8),
                        withName: "card_year"
                    )
                },
                to: url,
                method: .post
            )
            .responseData { response in
                
                print("""
                ==============================
                📥 UPDATE CARD RESPONSE
                ==============================
                URL: \(url)
                STATUS: \(response.response?.statusCode ?? 0)
                ==============================
                """)
                
                if let data = response.data,
                   let json = String(data: data, encoding: .utf8) {
                    
                    print("JSON:")
                    print(json)
                }
                
                switch response.result {
                    
                case .success(let data):
                    
                    do {
                        
                        let result = try JSONDecoder()
                            .decode(CommonResponse.self, from: data)
                        
                        continuation.resume(returning: result)
                        
                    } catch {
                        
                        print("❌ DECODING ERROR")
                        print(error)
                        
                        continuation.resume(throwing: error)
                    }
                    
                case .failure(let error):
                    
                    print("❌ UPDATE CARD FAILED")
                    print(error)
                    
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

struct EmptyResponse: Decodable {
    init() {}
}
