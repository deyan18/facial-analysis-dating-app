//
//  ChatView.swift
//  Cherry
//
//  Created by deyan on 7/10/21.
//

import SwiftUI

struct ChatRowView: View {
    @State var recentMessage: RecentMessageModel

    var body: some View {
        HStack(spacing: 20) {
            ImageCircular(url: recentMessage.url, size: 80)

            ZStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        SemiBoldText(texto: recentMessage.name)
                        Spacer()
                        Text(recentMessage.date.dateString())
                    }

                    HStack {
                        messageText(texto: recentMessage.text)
                    }
                }
                if !recentMessage.isRead {
                    newMessageIndicator
                }
            }
        }
        .frame(height: 80)
    }

    var newMessageIndicator: some View {
        Circle()
            .foregroundColor(.accentColor)
            .frame(width: 18, height: 18)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct messageText: View {
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
