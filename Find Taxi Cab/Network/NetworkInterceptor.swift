//
//  NetworkInterceptor.swift
//  Find Taxi Cab Driver
//
//  Created by Bhushan Kumar on 21/03/26.
//

import Alamofire
import Network

final class NetworkInterceptor: RequestInterceptor {
    
    static let shared = NetworkInterceptor()
    
    private let monitor = NWPathMonitor()
    private var isConnected = true
    
    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        monitor.start(queue: DispatchQueue.global())
    }
    
    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        
        guard request.retryCount < 3 else {
            completion(.doNotRetry)
            return
        }
        
        if !isConnected {
            completion(.retryWithDelay(3))
            return
        }
        
        if let afError = error.asAFError,
           afError.isSessionTaskError {
            completion(.retryWithDelay(2))
        } else {
            completion(.doNotRetry)
        }
    }
}
