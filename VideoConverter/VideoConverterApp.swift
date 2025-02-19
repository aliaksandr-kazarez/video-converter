//
//  VideoConverterApp.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/6/24.
//

import SwiftUI

@main
struct VideoConverterApp: App {
    @StateObject private var router = Router(.videoPickerScreen)
    
    var body: some Scene {
        WindowGroup {
            NavigatorView()
                .environmentObject(router)
        }
    }
}
