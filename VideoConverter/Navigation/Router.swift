//
//  Router.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 1/17/25.
//

import SwiftUI

class Router: ObservableObject {
    @Published private(set) var currentRoute: Route
    
    init(_ currentRoute: Route = .videoPickerScreen) {
        self.currentRoute = currentRoute
    }

    func navigate(to route: Route) {
        currentRoute = route
    }
}
