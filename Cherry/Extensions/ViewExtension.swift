//
//  ViewExtension.swift
//  Cherry
//
//  Created by Deyan on 26/2/22.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
