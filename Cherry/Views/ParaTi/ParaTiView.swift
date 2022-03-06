//
//  HomeView.swift
//  Cherry
//
//  Created by deyan on 26/9/21.
//

import CoreLocation
import SDWebImageSwiftUI
import SwiftUI

struct ParaTiView: View {
    @EnvironmentObject var vm: MainViewModel
    @EnvironmentObject var lm: LocationManager

    @State var usuarioSeleccionado: UserModel? = nil // Persona que se abre en el sheet

    // Toggles
    @State var abrirPerfil: Bool = false // Para abrir sheet con el perfil de la persona
    @State var abrirChat = false // Para abrir chat cuando se pulsa el boton de chat o like desde el perfil de una persona
    // Para la lista de perfiles
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // Link para abrir un chat que se acciona desde un perfil
                NavigationLink("", isActive: $abrirChat) {
                    ChatView()
                }

                navBar

                ScrollView(showsIndicators: false) {
                    VStack {
                        personaMasRecomendada
                        listaPersonas
                    }
                    .padding(.bottom, 40) // Para que no los ultimos no sean tapados por tabbar
                    .padding(.top, 70)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                vm.hideTabBar = false
                cambioUbicacion()
            }

            .alert(isPresented: $vm.apiError) {
                Alert(
                    title: Text("Problema con servidor"),
                    message: Text("No se han podido ordenar las personas por rasgos faciales. Pulsa el logo para volver a intentarlo.")
                )
            }
        }
    }
    
    func cambioUbicacion() {
        //vm.calcularRecomendaciones()
        guard let ubicacionGuardada = vm.currentUser?.location else {return}
        guard let ubicacionActual = lm.lastLocation else {return}
        let distancia = ubicacionGuardada.distance(from: ubicacionActual)
        print("DISTANCIA: \(distancia)")
        if distancia > MAX_DISTANCE_UPDATE {
            vm.updateLocation(location: ubicacionActual)
            vm.analyzeUsers()
        }
    }

    var navBar: some View {
        VStack {
            HStack {
                ZStack {
                    // Icono / Cargando
                    iconoBoton
                    // Titulo / Pulsar DEBUG
                    titulo
                    // Boton filtros
                    filtroBoton
                }
                Spacer()
            }
            .padding(.horizontal)
            .background(.thinMaterial)
            Spacer()
        }.zIndex(1)
    }
    
    var iconoBoton: some View{
        HStack {
            if vm.apiInUse {
                ProgressView()
                    .padding()
            } else {
                Button {
                    vm.analyzeUsers()
                } label: {
                    Image("Logo")
                        .resizable()
                        .frame(width: 60, height: 60)
                }
            }
            Spacer()
        }
    }
    
    var titulo: some View{
        HStack {
            if vm.showDebug { // Para mostrar info DEBUG
                VStack {
                    Text("ubi: \(vm.currentUser?.location.coordinate.longitude ?? -1.0):\(vm.currentUser?.location.coordinate.latitude ?? -1.0)")
                        .font(.caption)
                    Text("EMin: \(vm.currentUser?.ageMin ?? -1) EMax: \(vm.currentUser?.ageMax ?? -1) ")
                        .font(.caption)
                }
                .onTapGesture {
                    vm.showDebug.toggle()
                }
            } else {
                TitleText(texto: "Para Ti")
                    .onTapGesture {
                        vm.showDebug.toggle()
                    }
            }
        }
    }
    
    var filtroBoton: some View{
        HStack {
            Spacer()
            Button {
                withAnimation {
                    vm.openFilters.toggle()
                }
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.primary)
            }
        }
    }

    // Primera persona de la lista de usuariosCompatibles
    var personaMasRecomendada: some View {
        ZStack {
            VStack {
                // Foto grande
                BigImageCircular(url: vm.usersAnalyzed.first?.url1 ?? "")
                    .onTapGesture {
                        vm.selectedUser = vm.usersAnalyzed.first
                        usuarioSeleccionado = vm.usersAnalyzed.first
                        abrirPerfil.toggle()
                    }
                    .sheet(item: $usuarioSeleccionado) {
                        model in
                        PerfilView(usuario: model, esSheet: true, mostrarBotones: true, abrirChat: $abrirChat)
                    }

                SemiBoldTitle(vm.usersAnalyzed.first?.name ?? "")

                if vm.showDebug {
                    Text("ubi: \(vm.usersAnalyzed.first?.location.coordinate.longitude ?? -1.0):\(vm.usersAnalyzed.first?.location.coordinate.latitude ?? -1.0)")
                        .font(.caption)
                    Text("disRasgos: \(vm.usersAnalyzed.first?.distanceFeatures ?? -1.0)")
                        .font(.caption)
                }
            }
            if(!vm.usersAnalyzed.isEmpty){
                badge
            }
        }
    }

    var badge: some View {
        Text("+RECOMENDADO")
            .font(.caption)
            .semibold()
            .padding(10)
            .foregroundColor(.white)
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .offset(x: 100, y: -170)
            .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
    }

    // Lista con el resto de personas en usuariosCompatibles
    var listaPersonas: some View {
        LazyVGrid(columns: columns) {
            ForEach(vm.usersAnalyzed, id: \.self) { usuario in
                if usuario.uid != vm.usersAnalyzed.first?.uid {
                    VStack {
                        ImageCircular(url: usuario.url1, size: 108)
                        SemiBoldText(texto: usuario.name)
                        if vm.showDebug {
                            Text("ubi: \(usuario.location.coordinate.longitude):")
                                .font(.caption)
                            Text("\(usuario.location.coordinate.latitude)")
                                .font(.caption)
                            Text("dR: \(usuario.distanceFeatures)")
                                .font(.caption)
                        }
                    }
                    .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                    .onTapGesture { // Al pulsar abrimos sheet con el perfil
                        vm.selectedUser = usuario
                        usuarioSeleccionado = usuario
                        abrirPerfil.toggle()

                    }.sheet(item: $usuarioSeleccionado) {
                        model in
                        PerfilView(usuario: model, esSheet: true, mostrarBotones: true, abrirChat: $abrirChat)
                    }
                }
            }
        }.padding(.horizontal)
    }
}
