//
//  ChatView.swift
//  Cherry
//
//  Created by deyan on 18/10/21.
//

import SwiftUI
import SwiftUIX

struct ChatView: View {
    @EnvironmentObject var vm: MainViewModel
    @StateObject var chatVM: ChatViewModel = ChatViewModel()

    @State private var textfieldText = ""
    @FocusState private var isFocused


    var body: some View {
        ZStack() {
            GeometryReader { reader in
                ScrollView {
                    ScrollViewReader { scrollReader in
                        getMessagesView(viewWidth: reader.size.width)
                            .padding()

                        // Scrolls to new message
                        Spacer()
                            .frame(height: 60)
                            .id("bottom")
                            .onReceive(chatVM.$messages) { _ in
                                    DispatchQueue.main.async {
                                        withAnimation(.easeOut(duration: 0.5)) {
                                        scrollReader.scrollTo("bottom", anchor: .bottom)
                                    }
                                }
                            }
                            .onAppear {
                                DispatchQueue.main.async {
                                    scrollReader.scrollTo("bottom", anchor: .bottom)
                                }
                            }
                    }
                }
                .focused($isFocused)
                .onTapGesture {
                    hideKeyboard()
                }
            }

            VStack{
                Spacer()
                toolbarView()

            }
            
        }

        .navigationTitle(vm.selectedUser?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing:
            NavBarProfile()
        )
        .onAppear {
            onStart()
        }
    }

    private func onStart() {
        chatVM.selectedUser = vm.selectedUser!
        chatVM.currentUser = vm.currentUser
        chatVM.fetchMessages()
        chatVM.markAsRead()
        vm.hideTabBar = true
        
    }

    private func toolbarView() -> some View {
        VStack {
            let height: CGFloat = 37
            HStack {
                MessageTextField(placeholder: "Mensaje...", height: height, text: $textfieldText)
                    .focused($isFocused)

                Button(action: {
                    withAnimation(.spring()) {
                        self.sendMessage()
                    }

                }) {
                    SendMessageButton(height: height, texto: $textfieldText)
                }
                .disabled(textfieldText.isEmpty)
            }
            .frame(height: height)
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private func sendMessage() {
        chatVM.sendMessage(text: textfieldText, date: Date.now)
        textfieldText = ""
    }

    private func getMessagesView(viewWidth: CGFloat) -> some View {
        VStack(spacing: 1) {
            ForEach(chatVM.messages.indices, id: \.self) { index in
                let message = chatVM.messages[index]
                let isReceived = message.senderUID == vm.selectedUser?.uid

                if index == 0 { // Always shows date before first message
                    DateSeparator(date: message.date, firstMessage: true)

                } else { // Checks if theres a date difference with previous message
                    let previousMessage = chatVM.messages[index - 1]

                    if previousMessage.date.daysBetween(date: message.date) >= 1 {
                        DateSeparator(date: message.date)
                    }
                }

                if message.text == "*like*" {
                    if message.senderUID == vm.selectedUser!.uid {
                        LikeMessage(isRead: true, name: vm.selectedUser?.name ?? "")
                    } else {
                        LikeMessage(isRead: false, name: vm.selectedUser?.name ?? "")
                    }

                } else {
                    MessageBubble(isReceived: isReceived, message: message, viewWidth: viewWidth)
                }
            }
        }
    }
}

private struct LikeMessage: View {
    var isRead: Bool
    var name: String

    var body: some View {
        HStack{
            Spacer()
            if isRead {
                Text("¡\(name) le ha dado 💜 a tu perfil!")
                    .font(.footnote)
                    .padding(8)

            } else {
                Text("¡Has dado 💜 al perfil de \(name)!")
                    .font(.footnote)
                    .padding(8)
            }
            Spacer()

        }
        
    }
}

private struct MessageTextField: View {
    var placeholder: String
    var height: CGFloat
    @Binding var text: String
    var body: some View {
        TextField(placeholder, text: $text)
            .padding(.horizontal, 10)
            .frame(height: height)
            .background(Color.secondarySystemFill, in: RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color(UIColor.systemGray4), lineWidth: 1))
    }
}

private struct SendMessageButton: View {
    var height: CGFloat
    @Binding var texto: String
    var body: some View {
        Image(systemName: "paperplane.fill")
            .foregroundColor(.white)
            .frame(width: height, height: height)
            .background(
                Circle()
                    .foregroundColor(texto.isEmpty ? .gray : .accentColor)
            )
    }
}

private struct DateSeparator: View {
    var date: Date
    var firstMessage: Bool = false

    var body: some View {
        VStack {
            if !firstMessage {
                Divider().padding(.top)
            }
            Text(date.dateString())
                .font(.caption)
                .padding(8)
                .foregroundColor(.gray)
        }
    }
}

private struct MessageBubble: View {
    let isReceived: Bool
    let message: MessageModel
    let viewWidth: CGFloat
    let calendar = Calendar.current
    let textColor = Color.white

    var body: some View {
        HStack {
            ZStack {
                HStack {
                    if !isReceived {
                        hourMinutes
                    }
                    Text(message.text)
                        .foregroundColor(textColor)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .background(isReceived ? Color.gray : Color.accentColor)
                        .cornerRadius(25)
                    if isReceived {
                        hourMinutes
                    }
                }
            }
            .frame(width: viewWidth * 0.7, alignment: isReceived ? .leading : .trailing)
            .padding(.top, 3)
        }
        .frame(maxWidth: .infinity, alignment: isReceived ? .leading : .trailing)
    }
    
    private func getMinutes() -> String{
        let minutes = Calendar.current.dateComponents([.minute], from: message.date).minute!
        return String(format: "%02d", minutes)
    }
    
    private func getHour() -> String{
        let hour = Calendar.current.dateComponents([.hour], from: message.date).hour!
        return String(hour)
    }
    
    var hourMinutes: some View {
        Text("\(getHour()):\(getMinutes())")
            .font(.caption).foregroundColor(.gray)
            .padding(.leading, 0)
    }
}

private struct NavBarProfile: View {
    @EnvironmentObject var vm: MainViewModel
    @State var showSheet: Bool = false
    @State var noSeUtiliza = false
    var body: some View {
        HStack {
            ImageCircular(url: vm.selectedUser?.url1 ?? "", size: 40)
        }.onTapGesture {
            showSheet.toggle()
        }
        .sheet(isPresented: $showSheet, onDismiss: {
        }, content: {
            ProfileView(user: vm.selectedUser!, isSheet: true, showChatLikeButtons: false, openChat: $noSeUtiliza)

        })
    }
}
