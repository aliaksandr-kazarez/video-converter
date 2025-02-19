//
//  ContentView.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/13/24.
//

import SwiftUI

struct AnimationView: View {
    @Namespace private var animationNamespace
    @State private var isButtonInToolbar = false

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Button("Move to Toolbar") {
                    withAnimation(.easeInOut(duration: 0.5)) { isButtonInToolbar.toggle() }
                }
                .buttonStyle(.borderedProminent)
                .hidden(isButtonInToolbar)
                .matchedGeometryEffect(
                    id: "button", in: animationNamespace, properties: .position, isSource: !isButtonInToolbar)

                Spacer()
            }
            .navigationTitle("Toolbar Animation")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Move to Toolbar") {
                        withAnimation(.easeInOut(duration: 0.5)) { isButtonInToolbar.toggle() }
                    }
                    .hidden(!isButtonInToolbar)
                    .matchedGeometryEffect(
                        id: "button",
                        in: animationNamespace,
                        properties: .position,
                        isSource: isButtonInToolbar
                    )
                }
            }
        }
    }
}

#Preview {
    AnimationView()
}
