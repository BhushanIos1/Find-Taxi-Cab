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
            // Decode the response as what the caller actually asked for, first.
            //
            // This used to try `APIResponse<T>` ahead of the direct decode, and
            // that quietly broke every endpoint answering
            // `{"result": "success", "data": { ...something else... }}`.
            // `/miles_cal` is the clearest case: the wrapper matched, saw
            // `result == "success"`, then decoded its *inner* `data` object as
            // the caller's `CommonResponse`. Every field on that type is
            // optional, so it "succeeded" — returning an empty value with
            // `result == nil`. The caller read that as a failure and reported
            // "Could Not Submit Fare" for a fare the server had accepted.
            //
            // Trying T first means the envelope is only consulted when the
            // response genuinely isn't the shape the caller expected.
            if let direct = try? JSONDecoder().decode(T.self, from: data) {
                return direct
            }
            
            if let decoded = try? JSONDecoder().decode(APIResponse<T>.self, from: data) {
                
                if decoded.isSuccess {
                    
                    if let data = decoded.data {
                        print("ℹ️ Decoded via APIResponse envelope")
                        return data
                    }
                    
                    if T.self == EmptyResponse.self {
                        return EmptyResponse() as! T
                    }
                }
            }
            
            // Neither shape fits — let the real error surface.
            let direct = try JSONDecoder().decode(T.self, from: data)
            return direct
            
        } catch {
            print("❌ DECODING ERROR:", error)
            throw NetworkError.decodingError
        }
    }
}

struct EmptyResponse: Decodable {
    init() {}
}
