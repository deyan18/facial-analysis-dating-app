//
//  ChatsView.swift
//  Cherry
//
//  Created by deyan on 5/10/21.
//

import SwiftUI

struct ChatsView: View {
    @EnvironmentObject var vm: MainViewModel
    @State var abrirChat = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(vm.recentMessages, id: \.self) { reciente in
                        FilaChatView(reciente: reciente)
                            .contentShape(Rectangle()) // Para que se pueda pulsar sobre toda la fila
                            .onTapGesture {
                                // Buscamos el usuario correspondiente a ese mensaje
                                vm.users.forEach { u in
                                    if (reciente.senderUID != vm.currentUser?.uid && u.uid == reciente.senderUID) || (u.uid == reciente.receiverUID) {
                                        vm.selectedUser = u
                                        return
                                    }
                                }
                                abrirChat.toggle()
                            }
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.bottom, 40) // Para que no lo tape la tabbar
                .navigationTitle("Chats")


                // Abre el chat correspondiente
                NavigationLink("", isActive: $abrirChat) {
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
