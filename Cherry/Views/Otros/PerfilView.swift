//
//  PerfilView.swift
//  Cherry
//
//  Created by deyan on 26/9/21.
//

import SDWebImageSwiftUI
import SwiftUI
import WrappingStack

struct PerfilView: View {
    @StateObject var chatVM: ChatViewModel = ChatViewModel()
    @EnvironmentObject var vm: MainViewModel
    @Environment(\.presentationMode) var presentationMode

    // Variables que se reciben
    var usuario: UserModel
    var esSheet: Bool
    var mostrarBotones: Bool
    @Binding var abrirChat: Bool // Toggle para abrir chat en otra vista

    var body: some View {
        ScrollView(showsIndicators: false) {
            if esSheet {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.regularMaterial)
                    .frame(width: 50, height: 8)
                    .padding(.top)
            }

            ZStack { // Lista de fotos
                tabsFotos

                // Se puede abrir como sheet o como una vista
                if esSheet {
                    botonAtras
                }
            }.frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)

            nombreEdad

            if mostrarBotones {
                botones
            }
            AboutMeView(heading: "Sobre mi", text: usuario.aboutMe)
            atributos
            Spacer()
        }.onAppear {
            cargarDatos()
        }
    }

    private func cargarDatos() {
        if vm.selectedUser != nil {
            chatVM.selectedUser = vm.selectedUser
        }
        chatVM.currentUser = vm.currentUser
    }

    var tabsFotos: some View {
        TabView {
            ForEach(usuario.urls, id: \.self) { url in
                VStack {
                    WebImage(url: URL(string: url))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenWidth * 0.9)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
    }

    var botonAtras: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 13, height: 13)
                    .padding(14)
                    .background(.thinMaterial, in: Circle())
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
            }

            Spacer()
        }.padding(30)
    }

    var nombreEdad: some View {
        HStack {
            Text(usuario.name)
                .font(.title)
                .fontWeight(.semibold)
            Text("\(usuario.age)")
                .font(.title2)
            AttributeView(text: usuario.gender)
        }
    }

    var botones: some View {
        HStack(spacing: 20.0) {
            // Boton like
            Button {
                chatVM.sendMessage(text: "*like*", date: Date.now)
                abrirChat = true
                presentationMode.dismiss()
            } label: {
                IconButtonCustom(icon: "heart.fill", colorIcon: Color.accentColor)
            }

            // Boton chat
            Button {
                abrirChat = true
                presentationMode.dismiss()
            } label: {
                IconButtonCustom(icon: "message.fill", colorIcon: Color.gray)
            }
        }
        .padding(.bottom)
        .shadow(color: .black.opacity(0.07), radius: 3, x: -3, y: -3)
        .shadow(color: .black.opacity(0.07), radius: 3, x: 3, y: 3)
    }

    var coincide = false
    var atributos: some View {
        WrappingHStack(id: \.self, horizontalSpacing: 6) {
            ForEach(usuario.attributes, id: \.self) { a in
                AttributeView(text: a, matches: atributoCoincide(texto: a))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40) // Para que no lo tape la tabbar
    }

    private func atributoCoincide(texto: String) -> Bool {
        if !esSheet { return false }

        for atributo in vm.currentUser!.attributes {
            if atributo == texto {
                return true
            }
        }

        return false
    }
}
