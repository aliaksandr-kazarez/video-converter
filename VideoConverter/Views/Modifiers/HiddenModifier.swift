//
//  View+hidden.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/13/24.
//

import SwiftUICore

struct HiddenModifier: ViewModifier {
    let isHidden: Bool
        
    func body(content: Content) -> some View {
        if isHidden {
            content.hidden()
        } else {
            content
        }
    }
}

extension View {
    func hidden(_ isHidden: Bool) -> some View {
        self.modifier(HiddenModifier(isHidden: isHidden))
    }
}
