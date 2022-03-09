//
//  ManualUsuarioView.swift
//  Cherry
//
//  Created by Deyan on 23/2/22.
//

import SwiftUI

struct ManualUsuarioView: View {
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                Text("Primeros Pasos")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Divider()
                Text("¿Cómo me registro?")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Pulsa el siguiente botón:")
                    .font(.callout)
                    .padding(1)
                HStack{
                    Spacer()
                    Image("MU:registro")
                        .resizable()
                        .sizeToFit()
                        .frame(width: 300)
                    Spacer()
                }
                Text("A continuación deberás proporcionar un correo y una contraseña para crear tu cuenta. Trás esto ")
                    .font(.callout)
                    .padding(1)
                Spacer()
            }.padding()
        }
        
    }
}
