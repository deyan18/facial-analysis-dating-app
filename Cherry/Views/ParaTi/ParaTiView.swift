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

    @State var usuarioSeleccionado: UsuarioModel? = nil // Persona que se abre en el sheet

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
                cargarDatos()
            }
            .onChange(of: vm.usuarioPrincipal?.ubicacion) { _ in
                cambioUbicacion()
            }
            .alert(isPresented: $vm.errorApi) {
                Alert(
                    title: Text("Problema con servidor"),
                    message: Text("No se han podido ordenar las personas por rasgos faciales. Pulsa el logo para volver a intentarlo.")
                )
            }
        }
    }
    
    private func cargarDatos() {
        vm.esconderBarra = false
        vm.usuarioPrincipal?.ubicacion = lm.lastLocation ?? CLLocation(latitude: 0.0, longitude: 0.0)
    }

    private func cambioUbicacion() {
        vm.calcularRecomendaciones()
        if vm.usuarioPrincipal?.ubicacion != nil {
            vm.actualizarUbicacion(ubicacion: vm.usuarioPrincipal?.ubicacion ?? CLLocation(latitude: 0.0, longitude: 0.0))
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
            if vm.apiEnUso {
                ProgressView()
                    .padding()
            } else {
                Button {
                    vm.fetchUsuarios()
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
            if vm.DEBUG { // Para mostrar info DEBUG
                VStack {
                    Text("ubi: \(vm.usuarioPrincipal?.ubicacion.coordinate.longitude ?? -1.0):\(vm.usuarioPrincipal?.ubicacion.coordinate.latitude ?? -1.0)")
                        .font(.caption)
                    Text("EMin: \(vm.usuarioPrincipal?.edadMin ?? -1) EMax: \(vm.usuarioPrincipal?.edadMax ?? -1) ")
                        .font(.caption)
                }
                .onTapGesture {
                    vm.DEBUG.toggle()
                }
            } else {
                TextTitulo(texto: "Para Ti")
                    .onTapGesture {
                        vm.DEBUG.toggle()
                    }
            }
        }
    }
    
    var filtroBoton: some View{
        HStack {
            Spacer()
            Button {
                withAnimation {
                    vm.abrirFiltro.toggle()
                }
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.primary)
            }
        }
    }

    // Primera persona de la lista de usuariosRango
    var personaMasRecomendada: some View {
        ZStack {
            VStack {
                // Foto grande
                FotoMasRecomendado(url: vm.usuariosRango.first?.url1 ?? "")
                    .onTapGesture {
                        vm.usuarioSeleccionado = vm.usuariosRango.first
                        usuarioSeleccionado = vm.usuariosRango.first
                        abrirPerfil.toggle()
                    }
                    .sheet(item: $usuarioSeleccionado) {
                        model in
                        PerfilView(usuario: model, esSheet: true, mostrarBotones: true, abrirChat: $abrirChat)
                    }

                SemiTitulo(vm.usuariosRango.first?.nombre ?? "")

                if vm.DEBUG {
                    Text("ubi: \(vm.usuariosRango.first?.ubicacion.coordinate.longitude ?? -1.0):\(vm.usuariosRango.first?.ubicacion.coordinate.latitude ?? -1.0)")
                        .font(.caption)
                    Text("disMetros: \(vm.usuariosRango.first?.distanciaMetros ?? -1.0)m")
                        .font(.caption)
                    Text("disRasgos: \(vm.usuariosRango.first?.distanciaRasgos ?? -1.0)")
                        .font(.caption)
                }
            }
            badge
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

    // Lista con el resto de personas en usuariosRango
    var listaPersonas: some View {
        LazyVGrid(columns: columns) {
            ForEach(vm.usuariosRango, id: \.self) { usuario in
                if usuario.uid != vm.usuariosRango.first?.uid {
                    VStack {
                        WebFotoCircular(url: usuario.url1, size: 108)
                        TextNombre(texto: usuario.nombre)
                        if vm.DEBUG {
                            Text("ubi: \(usuario.ubicacion.coordinate.longitude):")
                                .font(.caption)
                            Text("\(usuario.ubicacion.coordinate.latitude)")
                                .font(.caption)
                            Text("dM: \(usuario.distanciaMetros)")
                                .font(.caption)
                            Text("dR: \(usuario.distanciaRasgos)")
                                .font(.caption)
                        }
                    }
                    .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                    .onTapGesture { // Al pulsar abrimos sheet con el perfil
                        vm.usuarioSeleccionado = usuario
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
