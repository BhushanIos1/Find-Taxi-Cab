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
    
    /// Pops back to `route`, or to the root if it was never pushed.
    ///
    /// `HomeScreen` is rendered by `RootView` as the `NavigationStack`'s root —
    /// it is never appended to `routes` — so `.home` is not findable here. The
    /// old `guard ... else { return }` therefore made every `popTo(.home)` a
    /// silent no-op: cancelling a trip showed its toast and then left the rider
    /// sitting on the tracking screen. Falling back to the root is what "go back
    /// to home" actually means in this stack.
    func popTo(_ route: AppRoute) {
        
        guard let index = routes.lastIndex(of: route) else {
            popToRoot()
            return
        }
        
        routes = Array(routes.prefix(index + 1))
        
        path = NavigationPath()
        
        for route in routes {
            path.append(route)
        }
    }
    
    /// Clears everything above the root and pushes `route` in its place, so the
    /// stack becomes root → `route`.
    ///
    /// Done in one assignment on purpose: `popToRoot()` followed by `push()` in
    /// the same tick makes `NavigationStack` animate a pop and a push at once,
    /// which reads as a flicker.
    func replaceStack(with route: AppRoute) {
        
        routes = [route]
        
        var newPath = NavigationPath()
        newPath.append(route)
        path = newPath
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
