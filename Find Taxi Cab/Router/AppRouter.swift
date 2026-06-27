//
//  AppRouter.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 26/02/26.
//

import SwiftUI

final class AppRouter: ObservableObject {
    
    @Published var path = NavigationPath()
    
    private var routes: [AppRoute] = []
    
    // MARK: - PUSH
    func push(_ route: AppRoute) {
        routes.append(route)
        path.append(route)
    }
    
    // MARK: - POP
    func pop() {
        
        guard !routes.isEmpty else { return }
        
        routes.removeLast()
        path.removeLast()
    }
    
    func popToRoot() {
        routes.removeAll()
        path = NavigationPath()
    }
    
    func popTo(_ route: AppRoute) {
        
        guard let index =
                routes.lastIndex(of: route)
        else { return }
        
        routes = Array(routes.prefix(index + 1))
        
        path = NavigationPath()
        
        for route in routes {
            path.append(route)
        }
    }
    
    func replaceCurrent(with route: AppRoute) {
        
        if !routes.isEmpty {
            routes.removeLast()
        }
        
        routes.append(route)
        
        path = NavigationPath()
        
        for route in routes {
            path.append(route)
        }
    }
}
