//
//  AjustesView.swift
//  Cherry
//
//  Created by deyan on 9/10/21.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: MainViewModel
    
    @State var email: String = ""
    @State var passNew: String = ""
    @State var passConfirm: String = ""
    
    @State var alertSignOut = false
    @State var alertSaveError = false
    @State var alertDeleteAccount = false
    
    var body: some View {
        VStack{
            emailView
            Divider()
            passwordsView
            saveChangesButton
            if vm.showDebug{
                ipView
            }
            
            Spacer()
            HStack{
                signOutButton
                deleteAccountButton
            }
            Spacer().frame(height: UIDevice.isIPhone ? 50 : 80)
        }
        .padding()
        .onTapGesture {
            hideKeyboard()
        }
        .navigationTitle("Ajustes")
        .onAppear(){
            email = FirebaseManager.shared.auth.currentUser?.email ?? ""
        }
        .navigationBarItems(
            trailing:
                NavigationLink(
                    destination: UserManualView(),
                label:{
                    Image(systemName: "info.circle")
                }
            
        ))
    }
    
    var emailView: some View {
        VStack{
            SectionTitle("Correo Electrónico")
            TextFieldCustom(placeholder: "usuario@email.com", text: $email, disableAutocorrection: true, autocap: false)
        }.padding(.vertical)
    }
    
    var ipView: some View {
        VStack{
            SectionTitle("IP")
            TextFieldCustom(placeholder: "", text: $vm.apiURL, disableAutocorrection: true, autocap: false)
        }.padding(.vertical)
    }
    
    var passwordsView: some View {
        VStack{
            SectionTitle("Cambiar Contraseña")
            SecureFieldCustom(placeholder: "Contraseña Nueva", text: $passNew)
            SecureFieldCustom(placeholder: "Confirmar Contraseña", text: $passConfirm)
        }.padding(.vertical)
    }
    
    var saveChangesButton: some View {
        Button {
            hideKeyboard()
            saveChanges()
        } label: {
            ButtonCustom(text: "Guardar", color: Color.accentColor)
                .disabled(!email.contains("@"))
                .disabled(!contraseniasValidas(passNew, passConfirm))
        }
        .padding(.top)
        .alert(isPresented: $alertSaveError) {
            Alert(
                title: Text("Error al guardar"),
                message: Text("Vuelva a revisar los datos introducidos.")
            )
        }
    }
    
    var signOutButton: some View {
        Button {
            hideKeyboard()
            alertSignOut = true
        } label: {
            ButtonCustom(text: "Cerrar Sesión", color: Color.orange)
        }
        .alert(isPresented: $alertSignOut) {
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
    
    var deleteAccountButton: some View {
        Button {
            hideKeyboard()
            alertDeleteAccount = true;
        } label: {
            ButtonCustom(text: "Eliminar Cuenta", color: Color.red)
        }
        .alert(isPresented: $alertDeleteAccount) {
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
    
   

    private func saveChanges(){
        if(FirebaseManager.shared.auth.currentUser?.email != email){
            FirebaseManager.shared.auth.currentUser?.updateEmail(to: email, completion: { err in
                if let err = err {
                    alertSaveError.toggle()
                    print("Error cambiando email: \(err)")
                }
            })

        }
        
        if(passNew != ""){
            FirebaseManager.shared.auth.currentUser?.updatePassword(to: passNew, completion: { err in
                if let err = err {
                    alertSaveError.toggle()
                    print("Error cambiando contraseña: \(err)")
                }
            })
        }
    }
    
    private func contraseniasValidas(_ contraseniaNueva: String, _ contraseniaConfirmar: String) -> Bool{
        return (contraseniaNueva == contraseniaConfirmar && contraseniaNueva.count >= 6) || (contraseniaNueva == "" && contraseniaConfirmar == "")
    }
}

