//
//  RegistrarseView.swift
//  Cherry
//
//  Created by Aula11 on 26/10/21.
//

import Firebase
import SwiftUI

struct SignUpView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var passwordConfirm: String = ""

    @State var alertSignUpError = false

    @Binding var openSignUp: Bool
    @State var openCustomizeProfile: Bool = false

    var body: some View {
        if openCustomizeProfile {
            CustomizeProfileView()
                .transition(AnyTransition.backslide)
                .zIndex(1)
        } else {
            VStack {
                VStack {
                    // Header
                    backButton
                    Spacer()
                    LogoSignIn()
                    TitleText(texto: "Registrarse")
                        .padding(.bottom, 20)

                    // Campos de texto
                    TextFieldCustom(placeholder: "Correo Electrónico", text: $email, disableAutocorrection: true, autocap: false)
                    SecureFieldCustom(placeholder: "Contraseña", text: $password)
                    SecureFieldCustom(placeholder: "Confirmar Contraseña", text: $passwordConfirm)
                    Spacer()

                    signUpButton
                    Spacer()
                }.padding()
            }
            .frame(width: UIScreen.screenWidth * (UIDevice.isIPhone ? 0.8 : 0.45), height: UIScreen.screenHeight * (UIDevice.isIPhone ? 0.7 : 0.6 ))
            .background(.ultraThinMaterial)
            .mask(RoundedRectangle(cornerRadius: CARD_RADIUS, style: .continuous))
            .onTapGesture {
                hideKeyboard()
            }
            .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
            .padding(UIDevice.isIPhone ? 40 : 200)
            
        }
    }

    var backButton: some View {
        HStack {
            Button {
                hideKeyboard()
                withAnimation(.spring(response: SPRING_RESPONSE, dampingFraction: SPRING_DAMPING, blendDuration: 0)) {
                    openSignUp = false
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

    var signUpButton: some View {
        Button {
            hideKeyboard()
            // Comprobar que los datos son correctos
            if email != "" && password != "" && passwordConfirm != "" {
                signUp()
            }
        } label: {
            ButtonCustom(text: "Registrarse", color: Color.accentColor)
                .padding(.top, 20)
                
        }
        .disabled(email != "" && !email.contains("@"))
        .disabled(email != "" && password.count < 6)
        .disabled(password != passwordConfirm)
        .disabled(password.count != passwordConfirm.count)
    // Para que el boton este deshabilitado solo cuando se empiece a escribir
        .alert(isPresented: $alertSignUpError) {
            Alert(
                title: Text("Error Registro"),
                message: Text("Este correo ya se encuantra registrado")
            )
        }
    }

    private func signUp() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                alertSignUpError = true
                if SHOW_DEBUG_CONSOLE {
                    print("Error Registro: ", err)
                }
                return
            }
            if SHOW_DEBUG_CONSOLE {
                print("Registrado Correcto: \(result?.user.uid ?? "")")
            }

            // Hacemos login
            FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { _, err in
                if let err = err {
                    if SHOW_DEBUG_CONSOLE {
                        print("Error Login: ", err)
                    }
                    return
                }

                withAnimation(.spring(response: SPRING_RESPONSE, dampingFraction: SPRING_DAMPING, blendDuration: 0)) {
                    openCustomizeProfile.toggle()
                }
            }
        }
    }
}
