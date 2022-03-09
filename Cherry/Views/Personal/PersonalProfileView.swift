//
//  PersonalView.swift
//  Cherry
//
//  Created by deyan on 5/10/21.
//

import SwiftUI

struct PersonalProfileView: View {
    @EnvironmentObject var vm: MainViewModel
    @State var useless = false
    
    var body: some View {
        
        NavigationView{
            ProfileView(user: vm.currentUser!, isSheet: false, showChatLikeButtons: false, openChat: $useless)
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(){
                
                withAnimation(.spring()) {
                    vm.hideTabBar = false
                }
            }
            
            .navigationBarItems(
                //Edit profile button
                leading:
                    NavigationLink(
                        destination: EditarView(),
                    label:{
                        Text("Editar")
                    }
                    
                    ),
                //Settings button
                trailing:
                    NavigationLink(
                        destination: SettingsView(),
                    label:{
                        Image(systemName: "gear")
                    })
                    
                )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    
}
