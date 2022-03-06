//
//  ChatView.swift
//  Cherry
//
//  Created by deyan on 7/10/21.
//

import SwiftUI

struct FilaChatView: View {
    @State var reciente: RecentMessageModel

    var body: some View {
        HStack(spacing: 20) {
            ImageCircular(url: reciente.url, size: 80)

            ZStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        SemiBoldText(texto: reciente.name)
                        Spacer()
                        Text(reciente.date.dateString())
                    }

                    HStack {
                        TextDentroChat(texto: reciente.text)
                    }
                }
                if !reciente.isRead {
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
