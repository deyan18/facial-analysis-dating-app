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

    // Para textfield
    @State private var texto = ""
    @FocusState private var isFocused


    var body: some View {
        ZStack() {
            GeometryReader { reader in
                ScrollView {
                    ScrollViewReader { scrollReader in
                        getMessagesView(viewWidth: reader.size.width) // Lista de mensajes
                            .padding()

                        // Para que se coloque en el sitio adecuado
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
                toolbarView() // Barra con textfield y boton

            }
            
        }

        .navigationTitle(vm.selectedUser?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing:
            NavBarPerfil()
        )
        .onAppear {
            comienzo()
        }
    }

    private func comienzo() {
        chatVM.selectedUser = vm.selectedUser!
        chatVM.currentUser = vm.currentUser
        chatVM.fetchMessages()
        chatVM.markAsRead()
        //withAnimation(.spring()) {
            vm.hideTabBar = true
        //}
    }

    // Barra con textfield y boton
    func toolbarView() -> some View {
        VStack {
            let height: CGFloat = 37 // Altura de todo
            HStack {
                TextFieldMensaje(placeholder: "Mensaje...", height: height, texto: $texto)
                    .focused($isFocused)

                Button(action: {
                    withAnimation(.spring()) {
                        enviarMensaje()
                    }

                }) {
                    BotonSend(height: height, texto: $texto)
                }
                .disabled(texto.isEmpty)
            }
            .frame(height: height)
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    func enviarMensaje() {
        chatVM.sendMessage(text: texto, date: Date.now)
        texto = ""
    }

    // Burbujas de mensajes
    func getMessagesView(viewWidth: CGFloat) -> some View {
        VStack(spacing: 1) {
            ForEach(chatVM.messages.indices, id: \.self) { index in
                let mensaje = chatVM.messages[index]
                let esRecibido = mensaje.senderUID == vm.selectedUser?.uid // Comprobamos si hemos recibido o enviado el mensaje

                if index == 0 { // Si es el primer mensaje siempre mostramos la fecha antes
                    SeparadorFecha(fecha: mensaje.date, esComienzo: true)

                } else { // Comprobamos si hay una diferencia de un día entre este mensaje y el anterior
                    let mensajeAnterior = chatVM.messages[index - 1]

                    if mensajeAnterior.date.daysBetween(date: mensaje.date) >= 1 {
                        SeparadorFecha(fecha: mensaje.date)
                    }
                }

                // Comprobamos si el mensaje es un like
                if mensaje.text == "*like*" {
                    if mensaje.senderUID == vm.selectedUser!.uid {
                        mensajeLike(esRecibido: true, nombre: vm.selectedUser?.name ?? "")
                    } else {
                        mensajeLike(esRecibido: false, nombre: vm.selectedUser?.name ?? "")
                    }

                } else {
                    BurbujaMensaje(esRecibido: esRecibido, mensaje: mensaje, viewWidth: viewWidth)
                }
            }
        }
    }
}

// Mensaje like que hemos podido enviar o recibir
struct mensajeLike: View {
    var esRecibido: Bool
    var nombre: String

    var body: some View {
        HStack{
            Spacer()
            if esRecibido {
                Text("¡\(nombre) le ha dado 💜 a tu perfil!")
                    .font(.footnote)
                    .padding(8)

            } else {
                Text("¡Has dado 💜 al perfil de \(nombre)!")
                    .font(.footnote)
                    .padding(8)
            }
            Spacer()

        }
        
    }
}

struct TextFieldMensaje: View {
    var placeholder: String
    var height: CGFloat
    @Binding var texto: String
    var body: some View {
        TextField(placeholder, text: $texto)
            .padding(.horizontal, 10)
            .frame(height: height)
            .background(Color.secondarySystemFill, in: RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color(UIColor.systemGray4), lineWidth: 1))
    }
}

struct BotonSend: View {
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

struct SeparadorFecha: View {
    var fecha: Date
    var esComienzo: Bool = false

    var body: some View {
        VStack {
            if !esComienzo {
                Divider().padding(.top)
            }
            Text(fecha.dateString())
                .font(.caption)
                .padding(8)
                .foregroundColor(.gray)
        }
    }
}

struct BurbujaMensaje: View {
    var esRecibido: Bool
    var mensaje: MessageModel
    var viewWidth: CGFloat
    var calendar = Calendar.current
    var colorTexto = Color.white

    var body: some View {
        HStack {
            ZStack {
                HStack {
                    if !esRecibido { // Para colocar fecha en la parte izquierda
                        Text("\(Calendar.current.dateComponents([.hour], from: mensaje.date).hour!):\(Calendar.current.dateComponents([.minute], from: mensaje.date).minute!)")
                            .font(.caption).foregroundColor(.gray)
                            .padding(.leading, 0)
                    }
                    Text(mensaje.text)
                        .foregroundColor(colorTexto)
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 10)
                        .background(esRecibido ? Color.gray : Color.accentColor)
                        .cornerRadius(25)
                    if esRecibido { // Para colocar fecha en la parte derecha
                        Text("\(Calendar.current.dateComponents([.hour], from: mensaje.date).hour!):\(Calendar.current.dateComponents([.minute], from: mensaje.date).minute!)")
                            .font(.caption).foregroundColor(.gray)
                            .padding(.leading, 0)
                    }
                }
            }
            .frame(width: viewWidth * 0.7, alignment: esRecibido ? .leading : .trailing)
            .padding(.top, 3)
        }
        .frame(maxWidth: .infinity, alignment: esRecibido ? .leading : .trailing)
    }
}

// Icono que abre sheet con el usuario
struct NavBarPerfil: View {
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
            PerfilView(usuario: vm.selectedUser!, esSheet: true, mostrarBotones: false, abrirChat: $noSeUtiliza)

        })
    }
}
