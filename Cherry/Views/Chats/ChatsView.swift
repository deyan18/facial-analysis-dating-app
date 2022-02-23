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
                    ForEach(vm.recientes, id: \.self) { reciente in
                        FilaChatView(reciente: reciente)
                            .contentShape(Rectangle()) // Para que se pueda pulsar sobre toda la fila
                            .onTapGesture {
                                // Buscamos el usuario correspondiente a ese mensaje
                                vm.usuarios.forEach { u in
                                    if (reciente.emisorId != vm.usuarioPrincipal?.uid && u.uid == reciente.emisorId) || (u.uid == reciente.receptorId) {
                                        vm.usuarioSeleccionado = u
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
                .onAppear {
                    //vm.fetchRecientes()
                }

                // Abre el chat correspondiente
                NavigationLink("", isActive: $abrirChat) {
                    ChatView()
                }
            }.onAppear {
                withAnimation(.spring()) {
                    vm.esconderBarra = false
                }
            }.navigationBarTitleDisplayMode(.inline)
        }
    }
}
