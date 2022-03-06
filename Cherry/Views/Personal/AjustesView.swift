//
//  AjustesView.swift
//  Cherry
//
//  Created by deyan on 9/10/21.
//

import SwiftUI

struct AjustesView: View {
    @EnvironmentObject var vm: MainViewModel

    //Campos
    @State var correo: String = ""
    @State var contraseniaNueva: String = ""
    @State var contraseniaConfirmar: String = ""
    
    @State var alertaContrasenia = false
    @State var alertaCerrarSesion = false
    @State var problemaGuardar = false
    @State var alertaEliminar = false
    
    var body: some View {
        VStack{
            correoView
            Divider()
            contrasenias
            botonGuardar
            if vm.showDebug{
                ipView
            }
            
            Spacer()
            HStack{
                botonCerrarSesion
                botonEliminarCuenta
            }
            Spacer().frame(height: 50)
        }
        .padding()
        .onTapGesture {
            hideKeyboard()
        }
        .navigationTitle("Ajustes")
        .onAppear(){
            correo = FirebaseManager.shared.auth.currentUser?.email ?? ""
        }
        .navigationBarItems(
            trailing:
                NavigationLink(
                    destination: ManualUsuarioView(),
                label:{
                    Image(systemName: "info.circle")
                }
            
        ))
    }
    
    var correoView: some View {
        VStack{
            SectionTitle("Correo Electrónico")
            TextFieldCustom(placeholder: "usuario@email.com", text: $correo, disableAutocorrection: true, autocap: false)
        }.padding(.vertical)
    }
    
    var ipView: some View {
        VStack{
            SectionTitle("IP")
            TextFieldCustom(placeholder: "", text: $vm.apiURL, disableAutocorrection: true, autocap: false)
        }.padding(.vertical)
    }
    
    var contrasenias: some View {
        VStack{
            SectionTitle("Cambiar Contraseña")
            SecureFieldCustom(placeholder: "Contraseña Nueva", text: $contraseniaNueva)
            SecureFieldCustom(placeholder: "Confirmar Contraseña", text: $contraseniaConfirmar)
        }.padding(.vertical)
    }
    
    var botonGuardar: some View {
        Button {
            hideKeyboard()
            guardar()
        } label: {
            ButtonCustom(text: "Guardar", color: Color.accentColor)
                .disabled(!correo.contains("@"))
                .disabled(!contraseniasValidas(contraseniaNueva, contraseniaConfirmar))
        }
        .padding(.top)
        .alert(isPresented: $problemaGuardar) {
            Alert(
                title: Text("Error al guardar"),
                message: Text("Vuelva a revisar los datos introducidos.")
            )
        }
    }
    
    var botonCerrarSesion: some View {
        Button {
            hideKeyboard()
            alertaCerrarSesion = true
        } label: {
            ButtonCustom(text: "Cerrar Sesión", color: Color.orange)
        }
        .alert(isPresented: $alertaCerrarSesion) {
            Alert(
                title: Text("Va a cerrar sesión"),
                message: Text("¿Está seguro que desea cerrar sesión?"),
                primaryButton: .default(
                    Text("Cancelar"),
                    action: {
                        
                    }
                ),
                secondaryButton: .destructive(
                    Text("Cerrar Sesión"),
                    action: {
                        withAnimation(.spring()) {
                            vm.signOut()
                        }
                    }
                )
            )
        }
    }
    
    var botonEliminarCuenta: some View {
        Button {
            hideKeyboard()
            alertaEliminar = true;
        } label: {
            ButtonCustom(text: "Eliminar Cuenta", color: Color.red)
        }
        .alert(isPresented: $alertaEliminar) {
            Alert(
                title: Text("Su cuenta se va a eliminar"),
                message: Text("¿Está seguro que desea eliminar su cuenta?"),
                primaryButton: .default(
                    Text("Cancelar"),
                    action: {
                        
                    }
                ),
                secondaryButton: .destructive(
                    Text("Eliminar"),
                    action: {
                        vm.deleteUserAccount()
                    }
                )
            )
        }
    }
    
   

    private func guardar(){
        if(FirebaseManager.shared.auth.currentUser?.email != correo){
            FirebaseManager.shared.auth.currentUser?.updateEmail(to: correo, completion: { err in
                if let err = err {
                    problemaGuardar.toggle()
                    print("Error cambiando email: \(err)")
                }
            })

        }
        
        if(contraseniaNueva != ""){
            FirebaseManager.shared.auth.currentUser?.updatePassword(to: contraseniaNueva, completion: { err in
                if let err = err {
                    problemaGuardar.toggle()
                    print("Error cambiando contraseña: \(err)")
                }
            })
        }
    }
    
    private func contraseniasValidas(_ contraseniaNueva: String, _ contraseniaConfirmar: String) -> Bool{
        return (contraseniaNueva == contraseniaConfirmar && contraseniaNueva.count >= 6) || (contraseniaNueva == "" && contraseniaConfirmar == "")
    }
}

