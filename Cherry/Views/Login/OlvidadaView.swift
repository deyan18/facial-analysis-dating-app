//
//  OlvidadaView.swift
//  Cherry
//
//  Created by Deyan on 16/2/22.
//

import SwiftUI

struct OlvidadaView: View {
    @State var correo: String = ""
    @Binding var mostrarOlvidada: Bool

    var body: some View {
        VStack{
            
        }.padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: RADIUSCARDS, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
            .padding()
    }
    
    
}


