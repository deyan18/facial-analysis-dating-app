//
//  TransicionesExtension.swift
//  Cherry
//
//  Created by Deyan on 13/2/22.
//

import SwiftUI

// Transicioones personalizadas
extension AnyTransition {
    static var backslide: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading))
    }

    static var upSlide: AnyTransition {
        AnyTransition.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom))
    }

    static var downSlide: AnyTransition {
        AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top))
    }
}
