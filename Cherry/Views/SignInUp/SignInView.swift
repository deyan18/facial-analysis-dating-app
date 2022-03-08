//
//  LoginView.swift
//  Cherry
//
//  Created by Aula11 on 26/10/21.
//

import CoreLocation
import CoreLocationUI
import Firebase
import SwiftUI
import UIKit

struct SignInView: View {
    @EnvironmentObject var vm: MainViewModel

    // Datos de los campos
    @State var email: String = ""
    @State var password: String = ""

    // Alertas
    @State var alertSignInError = false // Mostrar aviso de datos incorrectos
    @State var alertPassRecCorrect = false
    @State var alertPassRecError = false
    
    // Cambio de vista
    @State var openSignUp = false // Abrir vista registrar / Volver login
    @State var openPassRec = false
    
    //Toggle
    @State var openUserManual = false

    var body: some View {
        ZStack {
            CustomBG()
                .onTapGesture {
                    hideKeyboard()
                }
            if(vm.showUserManualButton){
            userManualButton
            }
            if openSignUp {
                SignUpView(openSignUp: $openSignUp)
                    .transition(AnyTransition.backslide)
                    .zIndex(1)
            } else {
                VStack {
                    VStack {
                        // Header
                        LogoSignIn()
                            .offset(y: 30)
                            .onTapGesture {
                                email = "alina@ual.es"
                                password = "123456"
                            }
                        

                        if(openPassRec){
                            passRecoveryElements
                                
                        }else{
                            signInElements
                        }
                        
                    }
                    .padding()
                    .navigationBarHidden(true)
                }
                .frame(width: UIScreen.screenWidth * (UIDevice.isIPhone ? 0.8 : 0.45), height: UIScreen.screenHeight * (UIDevice.isIPhone ? 0.65 : 0.5 ))
                .background(.ultraThinMaterial)
                .mask(RoundedRectangle(cornerRadius: CARD_RADIUS, style: .continuous))
                .onTapGesture {
                    hideKeyboard()
                }
                .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                .padding(UIDevice.isIPhone ? 40 : 200)
                .transition(AnyTransition.slide)
                
            }
            
            
        }.onAppear{
            vm.showUserManualButton = true
        }
    }
    
    var userManualButton: some View{
            VStack{
                Spacer()
                HStack{
                    Button {
                        withAnimation {
                            openUserManual.toggle()
                        }
                    } label: {
                        Image(systemName: "info")
                            .padding(14)
                            .background(.thinMaterial, in: Circle())
                            .foregroundColor(.primary)
                            .padding()
                    }
                    
                    Spacer()
                }
                .sheet(isPresented: $openUserManual) {
                    
                } content: {
                    ManualUsuarioView()
                }

            }
        
        
    }

    
    var passRecoveryElements: some View{
        VStack{
            TitleText(texto: "Recuperar Cuenta")
                .padding(.bottom, 20)
            TextFieldCustom(placeholder: "Correo Electrónico", text: $email, disableAutocorrection: true, autocap: false)
            passRecButton
            Spacer()
            passRecBackButton
                .alert(isPresented: $alertPassRecError) {
                    Alert(
                        title: Text("Error Credenciales"),
                        message: Text("El correo es incorrecto.")
                    )
                }
        }
    }
    
    var signInElements: some View{
        VStack{
            TitleText(texto: "Iniciar Sesión")
                .padding(.bottom, 20)
            // Campos de texto
            TextFieldCustom(placeholder: "Correo Electrónico", text: $email, disableAutocorrection: true, autocap: false)
            SecureFieldCustom(placeholder: "Contraseña", text: $password)
            // Botones
            passRecOpenButton
            signInButton
            Spacer()
            signUpButton
                .alert(isPresented: $alertSignInError) {
                    Alert(
                        title: Text("Error Login"),
                        message: Text("El usuario o la contraseña son incorrectos.")
                    )
                }
        }
    }

    
    var passRecButton: some View {
        Button {
            hideKeyboard()
            if(email != ""){
                recoverPasword()
            }
        } label: {
            ButtonCustom(text: "Continuar", color: Color.accentColor)
                .padding(.top)
        }
        .disabled(email != "" && !email.contains("@"))
        .alert(isPresented: $alertPassRecCorrect) {
            Alert(
                title: Text("Correo Enviado"),
                message: Text("Se ha enviado un link para restaurar la contraseña a su email"),
                dismissButton: .default(Text("OK"), action: { openPassRec = false})
            )
        }
    }
    
    var passRecBackButton: some View {
        Button {
            hideKeyboard()
            withAnimation {
                openPassRec = false

            }
        } label: {
            Label("Volver", systemImage: "chevron.backward")
                .foregroundColor(.primary.opacity(ELEMENT_OPACITY))

        }
    }
    
    private func recoverPasword(){
        FirebaseManager.shared.auth.sendPasswordReset(withEmail: email) { err in
            if let err = err{
                print("Error restaurando contraseña: \(err)")
                alertPassRecError = true
                return
            }
            alertPassRecCorrect = true

        }
    }

    var passRecOpenButton: some View {
        // Boton Contrasenia olvidada
        Button {
            hideKeyboard()
            withAnimation {
                openPassRec = true
            }
        } label: {
            Text("¿Has olvidado tu contraseña?")
                .font(.callout)
                .foregroundColor(.primary.opacity(ELEMENT_OPACITY))
        }
        .padding(.bottom, 40)
    }

    var signInButton: some View {
        Button {
            hideKeyboard()
            if email != "" && password != "" {
                signIn()
            }
        } label: {
            ButtonCustom(text: "Iniciar Sesión", color: Color.accentColor)
                .frame(height: 20)
        }
        .disabled(email != "" && !email.contains("@"))
        .disabled(email != "" && password.count < 6)
    }

    var signUpButton: some View {
        Button {
            hideKeyboard()
            withAnimation(.spring(response: SPRING_RESPONSE, dampingFraction: SPRING_DAMPING, blendDuration: 0)) {
                openSignUp.toggle()
            }
        } label: {
            Text("¿No tienes cuenta?")
                .frame(height: 40)
                .font(.callout)
                .foregroundColor(.primary.opacity(ELEMENT_OPACITY))
                .padding()
        }.padding(.top, 20)
    }

    private func signIn() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                alertSignInError = true
                if SHOW_DEBUG_CONSOLE {
                    print("Error Login: ", err)
                }
                return
            }

            if SHOW_DEBUG_CONSOLE {
                print("Login Correcto: \(result?.user.uid ?? "")")
            }
            email = ""
            password = ""
            vm.tabbarIndex = 0
            vm.fetchCurrentUser() // Cargamos el usuario actual

            withAnimation(.spring(response: SPRING_RESPONSE, dampingFraction: SPRING_DAMPING, blendDuration: 0)) {
                vm.signedIn = true
            }
        }
    }
}
