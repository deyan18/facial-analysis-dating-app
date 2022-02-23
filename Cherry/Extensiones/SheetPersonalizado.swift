//
//  SheetPersonalizado.swift
//  Cherry
//
//  Created by Deyan on 16/2/22.
//

import SwiftUI


import SwiftUI

enum SheetMode {
    case none
    case quarter
    case half
    case full
}

struct FlexibleSheet<Content: View>: View {
    
    let content: () -> Content
    var sheetMode: Binding<SheetMode>
    
    init(sheetMode: Binding<SheetMode>, @ViewBuilder content: @escaping () -> Content) {
        
        self.content = content
        self.sheetMode = sheetMode
        
    }
    
    private func calculateOffset() -> CGFloat {
        
        switch sheetMode.wrappedValue {
            case .none:
                return UIScreen.main.bounds.height
            case .quarter:
                return UIScreen.main.bounds.height - 200
            case .half:
                return UIScreen.main.bounds.height/2
            case .full:
                return 0
        }
        
    }
    
    var body: some View {
        content()
            .offset(y: UIScreen.main.bounds.height - 60)
            .animation(.spring())
            .edgesIgnoringSafeArea(.all)
    }
}
