//
//  MainView.swift
//  Cherry
//
//  Created by deyan on 29/9/21.
//

import SwiftUI
import SwiftUIX

struct MainView: View {
    @EnvironmentObject var vm: MainViewModel
    @EnvironmentObject var lm: LocationManager
    
    init() {
        // Para que la navbar no sea blanca
        let navBarAppearance = UINavigationBarAppearance()
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }

    var body: some View {
        if vm.signedIn {
            ZStack { // Acciones tabbar
                switch vm.tabbarIndex {
                case 0:
                    ForYouView()
                case 1:
                    ChatsView()
                case 2:
                    PersonalProfileView()
                default:
                    ForYouView()
                }

                // Tabbar
                if !vm.hideTabBar {
                    VStack {
                        Spacer()
                        TabBarCustom()
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .transition(.move(edge: .bottom))
                }

                // Para que el las vista de filtros quede por encima de todo
                if vm.openFilters {
                    FilterView()
                }
                
                // Para bloquear el acceso a la app si el acceso a la ubicacion esta deshabilitado
                if(lm.statusString == "denied"){
                    LocationCustomAlert()
                }
                    
                
            }
            .transition(AnyTransition.upSlide) // Cuando pasamos del login a la pantalla principal
            .onAppear { // Cuando cerramos y volvemos a iniciar sesion hace falta indicar que no hay que esconder la barra
                vm.hideTabBar = false
                
            }
        } else {
            SignInView()
                .transition(AnyTransition.downSlide) // Cuando pasamos del login a la pantalla principal
                
        }
    }
}

struct LocationCustomAlert: View {
    var body: some View {
        Color.black.opacity(0.6).ignoresSafeArea()
        VStack {
            Text("Ubicación Denegada")
                .font(.headline)
            Divider()
            Text("Para utilizar la app debe habilitar el acceso a la ubicación desde ajustes.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                
        }.padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CARD_RADIUS, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
            .padding()
    }
}


