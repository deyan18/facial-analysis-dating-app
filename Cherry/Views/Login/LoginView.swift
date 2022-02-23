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

struct LoginView: View {
    @EnvironmentObject var vm: MainViewModel
    //@EnvironmentObject var lm: LocationManager

    // Datos de los campos
    @State var correo: String = ""
    @State var contrasenia: String = ""

    // Alertas
    @State var alertProblemaLogin = false // Mostrar aviso de datos incorrectos
    @State var alertOlvidadaCorrecto = false
    @State var alertProblemaOlvidada = false
    
    // Cambio de vista
    @State var mostrarRegistrar = false // Abrir vista registrar / Volver login
    @State var mostrarOlvidada = false
    
    //Toggle
    @State var abrirManualUsuario = false

    var body: some View {
        ZStack {
            FondoPersonalizado()
            VStack{
                Spacer()
                HStack{
                    Button {
                        withAnimation {
                            abrirManualUsuario.toggle()
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
                .sheet(isPresented: $abrirManualUsuario) {
                    
                } content: {
                    ManualUsuarioView()
                }

            }
            if mostrarRegistrar {
                RegistrarseView(mostrarRegistrar: $mostrarRegistrar)
                    .transition(AnyTransition.backslide)
                    .zIndex(1) // Para ponerlo por encima (creo, si lo quito va mal...)
            } else {
                VStack {
                    VStack {
                        // Header
                        LogoLogin()
                            .offset(y: 30)
                        

                        if(mostrarOlvidada){
                            elementosOlvidada
                                
                        }else{
                            elementosLogin
                        }
                        
                    }
                    .padding()
                    .navigationBarHidden(true)
                }
                .frame(width: UIScreen.screenWidth * 0.8, height: UIScreen.screenHeight * 0.65)
                .background(.ultraThinMaterial)
                .mask(RoundedRectangle(cornerRadius: RADIUSCARDS, style: .continuous))
                .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                .padding(40)
                .transition(AnyTransition.slide)
                
            }
            
            
        }
    }
    
    var elementosOlvidada: some View{
        VStack{
            TextTitulo(texto: "Recuperar Cuenta")
                .padding(.bottom, 20)
            TextFieldPersonalizado(placeholder: "Correo Electrónico", texto: $correo, sinAutocorrector: true, mayusculas: false)
            botonRestaurar
            Spacer()
            botonVolver
                .alert(isPresented: $alertProblemaOlvidada) {
                    Alert(
                        title: Text("Error Credenciales"),
                        message: Text("El correo es incorrecto.")
                    )
                }
        }
    }
    
    var elementosLogin: some View{
        VStack{
            TextTitulo(texto: "Iniciar Sesión")
                .padding(.bottom, 20)
            // Campos de texto
            TextFieldPersonalizado(placeholder: "Correo Electrónico", texto: $correo, sinAutocorrector: true, mayusculas: false)
            SecureFieldPersonalizado(placeholder: "Contraseña", texto: $contrasenia)
            // Botones
            botonDatosOlvidados
            botonIniciarSesion
            Spacer()
            botonRegistrarse
                .alert(isPresented: $alertProblemaLogin) {
                    Alert(
                        title: Text("Error Login"),
                        message: Text("El usuario o la contraseña son incorrectos.")
                    )
                }
        }
    }

    
    var botonRestaurar: some View {
        Button {
            if(correo != ""){
                restaurarContrasenia()
            }
        } label: {
            BotonPersonalizado(texto: "Continuar", color: Color.accentColor)
                .padding(.top)
        }
        .disabled(correo != "" && !correo.contains("@"))
        .alert(isPresented: $alertOlvidadaCorrecto) {
            Alert(
                title: Text("Correo Enviado"),
                message: Text("Se ha enviado un link para restaurar la contraseña a su email"),
                dismissButton: .default(Text("OK"), action: { mostrarOlvidada = false})
            )
        }
    }
    
    var botonVolver: some View {
        Button {
            withAnimation {
                mostrarOlvidada = false

            }
        } label: {
            Label("Volver", systemImage: "chevron.backward")
                .foregroundColor(.primary.opacity(OPACITY))

        }
    }
    
    private func restaurarContrasenia(){
        FirebaseManager.shared.auth.sendPasswordReset(withEmail: correo) { err in
            if let err = err{
                print("Error restaurando contraseña: \(err)")
                alertProblemaOlvidada = true
                return
            }
            alertOlvidadaCorrecto = true

        }
    }

    var botonDatosOlvidados: some View {
        // Boton Contrasenia olvidada
        Button {
            withAnimation {
                mostrarOlvidada = true
            }
        } label: {
            Text("¿Has olvidado tu contraseña?")
                .font(.callout)
                .foregroundColor(.primary.opacity(OPACITY))
        }
        .padding(.bottom, 40)
    }

    var botonIniciarSesion: some View {
        Button {
            if correo != "" && contrasenia != "" {
                loginUsuario()
            }
        } label: {
            BotonPersonalizado(texto: "Iniciar Sesión", color: Color.accentColor)
                .frame(height: 20)
        }
        .disabled(correo != "" && !correo.contains("@"))
        .disabled(correo != "" && contrasenia.count < 6)
    }

    var botonRegistrarse: some View {
        Button {
            withAnimation(.spring(response: SPRINGRESPONSE, dampingFraction: SPRINGDAMPING, blendDuration: 0)) {
                mostrarRegistrar.toggle()
            }
        } label: {
            Text("¿No tienes cuenta?")
                .frame(height: 40)
                .font(.callout)
                .foregroundColor(.primary.opacity(OPACITY))
                .padding()
        }.padding(.top, 20)
    }

    private func loginUsuario() {
        FirebaseManager.shared.auth.signIn(withEmail: correo, password: contrasenia) { result, err in
            if let err = err {
                alertProblemaLogin = true
                if DEBUGCONSOLE {
                    print("Error Login: ", err)
                }
                return
            }

            if DEBUGCONSOLE {
                print("Login Correcto: \(result?.user.uid ?? "")")
            }
            correo = ""
            contrasenia = ""
            vm.tabbarIndex = 0
            vm.fetchUsuarioActual() // Cargamos el usuario actual

            withAnimation(.spring(response: SPRINGRESPONSE, dampingFraction: SPRINGDAMPING, blendDuration: 0)) {
                vm.usuarioLoggedIn = true
            }
        }
    }
}
