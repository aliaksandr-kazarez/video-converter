//
//  Router.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 1/17/25.
//


import SwiftUI

class Router: ObservableObject {
    @Published var currentRoute: Route
    
    init(_ currentRoute: Route = .home) {
        self.currentRoute = currentRoute
    }

    func navigate(to route: Route) {
        currentRoute = route
    }

    func resetToHome() {
        currentRoute = .home
    }
}
