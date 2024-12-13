//
//  PanelView.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/12/24.
//

import SwiftUI

struct PanelModifier<Background: ShapeStyle>: ViewModifier {
    private let background: Background

    init(background: Background) {
        self.background = background
    }

    func body(content: Content) -> some View {
        content
            .padding()
            .background(background)
            .cornerRadius(10)
            .shadow(radius: 2)
    }
}

extension View {
    func panel(background: some ShapeStyle = Color(.systemGray6)) -> some View {
        self.modifier(PanelModifier(background: background))
    }
}

#Preview {
    VStack {
        Text("Hello, World!")
            .panel()

        Text("Hello, World!")
            .panel(background: Color.red.opacity(0.8))
        Text("Hello, World!")
            .panel(background: .thinMaterial)

    }
}
