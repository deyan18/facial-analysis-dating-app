//
//  ChatsView.swift
//  Cherry
//
//  Created by deyan on 5/10/21.
//

import SwiftUI

struct ChatsView: View {
    @EnvironmentObject var vm: MainViewModel
    @State var openChat = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(vm.recentMessages, id: \.self) { reciente in
                        ChatRowView(recentMessage: reciente)
                            .contentShape(Rectangle()) // To tap on the whole view
                            .onTapGesture {
                                // Search for selected user
                                vm.users.forEach { user in
                                    if (reciente.senderUID != vm.currentUser?.uid && user.uid == reciente.senderUID) || (user.uid == reciente.receiverUID) {
                                        vm.selectedUser = user
                                        return
                                    }
                                }
                                openChat.toggle()
                            }
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.bottom, 40)
                .navigationTitle("Chats")

                // Opens chat
                NavigationLink("", isActive: $openChat) {
                    ChatView()
                }
            }.onAppear {
                withAnimation(.spring()) {
                    vm.hideTabBar = false
                }
            }.navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
