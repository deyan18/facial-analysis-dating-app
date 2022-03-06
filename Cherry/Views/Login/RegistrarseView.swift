//
//  RegistrarseView.swift
//  Cherry
//
//  Created by Aula11 on 26/10/21.
//

import Firebase
import SwiftUI

struct RegistrarseView: View {
    // Datos de los campos
    @State var correo: String = ""
    @State var contrasenia: String = ""
    @State var confirmar: String = ""

    @State var alertProblemaRegistro = false // Mostrar aviso de que el correo ya existe

    // Cambio de vista
    @Binding var mostrarRegistrar: Bool // Abrir vista registrar / Volver a login
    @State var mostrarCrearPerfil: Bool = false // Abrir vista crear perfil

    var body: some View {
        if mostrarCrearPerfil {
            CrearPerfilView()
                .transition(AnyTransition.backslide)
                .zIndex(1)
        } else {
            VStack {
                VStack {
                    // Header
                    botonAtras
                    Spacer()
                    LogoSignIn()
                    TitleText(texto: "Registrarse")
                        .padding(.bottom, 20)

                    // Campos de texto
                    TextFieldCustom(placeholder: "Correo Electrónico", text: $correo, disableAutocorrection: true, autocap: false)
                    SecureFieldCustom(placeholder: "Contraseña", text: $contrasenia)
                    SecureFieldCustom(placeholder: "Confirmar Contraseña", text: $confirmar)
                    Spacer()

                    botonRegistrarse
                    Spacer()
                }.padding()
            }
            .frame(width: UIScreen.screenWidth * 0.8, height: UIScreen.screenHeight * 0.7)
            .background(.ultraThinMaterial)
            .mask(RoundedRectangle(cornerRadius: CARD_RADIUS, style: .continuous))
            .onTapGesture {
                hideKeyboard()
            }
            .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
            .padding(40)
        }
    }

    var botonAtras: some View {
        HStack {
            Button {
                hideKeyboard()
                withAnimation(.spring(response: SPRING_RESPONSE, dampingFraction: SPRING_DAMPING, blendDuration: 0)) {
                    mostrarRegistrar = false
                }
            } label: {
                Image(systemName: "arrow.backward")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.primary.opacity(ELEMENT_OPACITY))
                    .padding(.top, 20)
                    .padding(.leading, 10)
            }
            Spacer()
        }
    }

    var botonRegistrarse: some View {
        Button {
            hideKeyboard()
            // Comprobar que los datos son correctos
            if correo != "" && contrasenia != "" && confirmar != "" {
                registrarUsuario()
            }
        } label: {
            ButtonCustom(text: "Registrarse", color: Color.accentColor)
                .padding(.top, 20)
                
        }
        .disabled(correo != "" && !correo.contains("@"))
        .disabled(correo != "" && contrasenia.count < 6)
        .disabled(contrasenia != confirmar)
        .disabled(contrasenia.count != confirmar.count)
    // Para que el boton este deshabilitado solo cuando se empiece a escribir
        .alert(isPresented: $alertProblemaRegistro) {
            Alert(
                title: Text("Error Registro"),
                message: Text("Este correo ya se encuantra registrado")
            )
        }
    }

    // Registra al usuario SOLO con el correo y la contrasenia
    private func registrarUsuario() {
        FirebaseManager.shared.auth.createUser(withEmail: correo, password: contrasenia) { result, err in
            if let err = err {
                alertProblemaRegistro = true
                if SHOW_DEBUG_CONSOLE {
                    print("Error Registro: ", err)
                }
                return
            }
            if SHOW_DEBUG_CONSOLE {
                print("Registrado Correcto: \(result?.user.uid ?? "")")
            }

            // Hacemos login
            FirebaseManager.shared.auth.signIn(withEmail: correo, password: contrasenia) { _, err in
                if let err = err {
                    if SHOW_DEBUG_CONSOLE {
                        print("Error Login: ", err)
                    }
                    return
                }

                withAnimation(.spring(response: SPRING_RESPONSE, dampingFraction: SPRING_DAMPING, blendDuration: 0)) {
                    mostrarCrearPerfil.toggle()
                }
            }
        }
    }
}
