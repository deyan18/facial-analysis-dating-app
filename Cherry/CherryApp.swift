//
//  CherryApp.swift
//  Cherry
//
//  Created by deyan on 18/9/21.
//

import Firebase
import SwiftUI

@main
struct CherryApp: App {
    @StateObject var vm: MainViewModel = MainViewModel()
    @StateObject var lm: LocationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(vm)
                .environmentObject(lm)
                .onAppear {
                    if FirebaseManager.shared.auth.currentUser != nil{
                        vm.fetchUsuarioActual()
                        vm.usuarioLoggedIn = true
                    }
                }
            
        }
    }
}
