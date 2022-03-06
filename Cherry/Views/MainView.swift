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
                    ParaTiView()
                case 1:
                    ChatsView()
                case 2:
                    PersonalView()
                default:
                    ParaTiView()
                }

                // Tabbar
                if !vm.hideTabBar {
                    VStack {
                        Spacer()
                        TabViewPersonalizado()
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .transition(.move(edge: .bottom))
                }

                // Para que el las vista de filtros quede por encima de todo
                if vm.openFilters {
                    FiltroView()
                }
                
                // Para bloquear el acceso a la app si el acceso a la ubicacion esta deshabilitado
                if(lm.statusString == "denied"){
                    AvisoUbicacion()
                }
                    
                
            }
            .transition(AnyTransition.upSlide) // Cuando pasamos del login a la pantalla principal
            .onAppear { // Cuando cerramos y volvemos a iniciar sesion hace falta indicar que no hay que esconder la barra
                vm.hideTabBar = false
                
            }
        } else {
            LoginView()
                .transition(AnyTransition.downSlide) // Cuando pasamos del login a la pantalla principal
                
        }
    }
}

struct AvisoUbicacion: View {
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


struct TabViewPersonalizado: View {
    @EnvironmentObject var vm: MainViewModel

    var elementosTabbar = [ElementoTabbar(indice: 0, nombre: "Para Ti", iconoNormal: "house", iconoSeleccionado: "house.fill"),
                           ElementoTabbar(indice: 1, nombre: "Chats", iconoNormal: "message", iconoSeleccionado: "message.fill"),
                           ElementoTabbar(indice: 2, nombre: "Perfil", iconoNormal: "person", iconoSeleccionado: "person.fill")]

    var body: some View {
        // Cuadro tabbar
        HStack {
            Spacer()
            ForEach(elementosTabbar, id: \.self) { elemento in
                // Cada boton del tabbar
                Button {
                    withAnimation(.spring(response: SPRING_RESPONSE, dampingFraction: SPRING_DAMPING, blendDuration: 0)) {
                        vm.tabbarIndex = elemento.indice
                    }
                } label: {
                    VStack {
                        // Si no esta seleccionado se muestra el icono normal, si lo esta se muestra el relelno
                        if vm.tabbarIndex != elemento.indice {
                            IconoTabbar(nombreIcono: elemento.iconoNormal)
                        } else {
                            IconoTabbar(nombreIcono: elemento.iconoSeleccionado)
                        }

                        TextoTabbar(nombre: elemento.nombre)
                    }.padding(.bottom, 4)
                }
                Spacer()
            }
        }
        .padding(EdgeInsets(top: 15, leading: 0, bottom: 20, trailing: 0))
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight * 0.08)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: BUTTON_TFIELD_RADIUS, style: .continuous))
        .background( // Circulo de color por detras
            Circle().fill(Color.accentColor).frame(width: 90)
                .offset(x: vm.tabbarIndex == 0 ? -103 : (vm.tabbarIndex == 1 ? 5 : +108))
        )
        .overlay( // Barrita que aparece encima del icono
            RoundedRectangle(cornerRadius: BUTTON_TFIELD_RADIUS)
                .fill(Color.accentColor)
                .frame(width: 28, height: 5)
                .frame(width: 90)
                .frame(maxHeight: .infinity, alignment: .top)
                .offset(x: vm.tabbarIndex == 0 ? -103 : (vm.tabbarIndex == 1 ? 5 : +108))
        )
        .shadow(color: .black.opacity(0.06), radius: 5, x: -5, y: -5)
        .shadow(color: .black.opacity(0.06), radius: 5, x: 5, y: 5)
    }
}

struct IconoTabbar: View {
    var nombreIcono: String

    var body: some View {
        Image(systemName: nombreIcono)
            .resizable()
            .frame(width: 27, height: 25)
            .foregroundColor(Color.primary.opacity(ELEMENT_OPACITY))
    }
}

struct TextoTabbar: View {
    var nombre: String

    var body: some View {
        Text(nombre)
            .font(.caption)
            .foregroundColor(Color.primary.opacity(ELEMENT_OPACITY))
    }
}

struct ElementoTabbar: Hashable {
    var indice: Int
    var nombre: String
    var iconoNormal: String
    var iconoSeleccionado: String
}
