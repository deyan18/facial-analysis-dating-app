//
//  PersonalView.swift
//  Cherry
//
//  Created by deyan on 5/10/21.
//

import SwiftUI

struct PersonalView: View {
    @EnvironmentObject var vm: MainViewModel
    
    @State var noSeUtiliza = false
    
    var body: some View {
        
        NavigationView{
            PerfilView(usuario: vm.usuarioPrincipal!, esSheet: false, mostrarBotones: false, abrirChat: $noSeUtiliza)
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(){
                
                withAnimation(.spring()) {
                    vm.esconderBarra = false
                }
            }
            
            .navigationBarItems(
                //Boton editar perfil
                leading:
                    NavigationLink(
                        destination: EditarView(),
                    label:{
                        Text("Editar")
                    }
                    
                    ),
                //Boton ajustes de cuenta
                trailing:
                    NavigationLink(
                        destination: AjustesView(),
                    label:{
                        Image(systemName: "gear")
                    })
                    
                )
        }
    }
    
    
}
