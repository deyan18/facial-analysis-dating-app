//
//  ChatView.swift
//  Cherry
//
//  Created by deyan on 7/10/21.
//

import SwiftUI

struct FilaChatView: View {
    @State var reciente: RecienteModel

    var body: some View {
        HStack(spacing: 20) {
            WebFotoCircular(url: reciente.urlFoto, size: 80)

            ZStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        TextNombre(texto: reciente.nombre)
                        Spacer()
                        Text(reciente.fecha.fechaString())
                    }

                    HStack {
                        TextDentroChat(texto: reciente.texto)
                    }
                }
                if !reciente.esLeido {
                    circuloPendiente
                }
            }
        }
        .frame(height: 80)
    }

    var circuloPendiente: some View {
        Circle()
            .foregroundColor(.accentColor)
            .frame(width: 18, height: 18)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct TextDentroChat: View {
    var texto: String

    var body: some View {
        Text(texto == "*like*" ? "💜💜💜" : texto)
            .foregroundColor(.gray)
            .lineLimit(2)
            .frame(height: 50, alignment: .top)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 40)
    }
}
