//
//  ButtonStyle.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 22/01/24.
//

import SwiftUI

struct ElasticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .elastic(active: configuration.isPressed)
    }
}

struct ElasticModifier: ViewModifier {
    var active: Bool
    @State var hovering = false
    @Environment(\.isEnabled) var isEnabled
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(active ? 0.95 : (hovering && isEnabled ? 1.025 : 1.0))
            .animation(.defaultSpring, value: active)
            .animation(.defaultSpring, value: hovering)
            .onHover {
                hovering = $0
            }
    }
}

extension Animation {
    static var defaultSpring: Self {
        .spring(response: 0.4, dampingFraction: 0.85)
    }
}

extension View {
    func elastic(active: Bool) -> some View {
        self.modifier(ElasticModifier(active: active))
    }
}
