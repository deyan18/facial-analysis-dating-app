//
//  FiltroView.swift
//  Cherry
//
//  Created by Deyan on 6/2/22.
//

import SwiftUI

struct FiltroView: View {
    @EnvironmentObject var vm: MainViewModel
    @Environment(\.defaultMinListRowHeight) var minRowHeight

    // Limites edad locales
    @State var min = 0
    @State var max = 0

    // Seleccion de rasgos locales
    @State private var rasgos = "Similares"
    var rasgosLista = ["Similares", "Diferentes"]

    var body: some View {
        Color.black.opacity(0.4).ignoresSafeArea()
        VStack {
            ZStack {
                botonCerrar
                SemiTitulo("Filtros")
            }

            Divider()
            elegirRasgos
            Divider()
            rangoEdad
            botonGuardar
        }.padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: RADIUSCARDS, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
            .padding()
            .onAppear {
                cargarDatos()
            }
    }

    
    private func cargarDatos(){
        if vm.usuarioPrincipal?.buscaSimilar ?? true {
            rasgos = "Similares"
        } else {
            rasgos = "Diferentes"
        }
        min = vm.usuarioPrincipal?.edadMin ?? 18
        max = vm.usuarioPrincipal?.edadMax ?? 99
    }
    
    private func guardar(){
        if rasgos == "Similares" {
            vm.usuarioPrincipal?.buscaSimilar = true
        } else {
            vm.usuarioPrincipal?.buscaSimilar = false
        }
        vm.usuarioPrincipal?.edadMin = min
        vm.usuarioPrincipal?.edadMax = max
        vm.actualizarLimitesEdad()
        vm.actualizarRasgosBusca()
        vm.calcularRecomendaciones()
    }
    
    var botonGuardar: some View{
        Button {
            guardar()
            withAnimation {
                vm.abrirFiltro = false
            }
        } label: {
            BotonPersonalizado(texto: "Guardar", color: .accentColor)
        }
    }

    
    var botonCerrar: some View{
        HStack {
            Spacer()
            Button {
                withAnimation {
                    vm.abrirFiltro = false
                }
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 13, height: 13)
                    .padding(14)
                    .background(.thinMaterial, in: Circle())
                    .foregroundColor(.primary)
            }
        }
    }

    var elegirRasgos: some View {
        VStack {
            HStack {
                Text("Rasgos")
                    .font(.headline)
                Spacer()
            }
            Picker("Rasgos", selection: $rasgos) {
                ForEach(rasgosLista, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
        }.padding(.vertical)
    }

    var rangoEdad: some View {
   
            HStack {
                VStack {
                    Text("Edad Mínima").font(.headline)
                    Picker("Mín edad", selection: $min) {
                        ForEach(18 ..< 100, id: \.self) {
                            Text("\($0)")
                                .foregroundColor(.primary)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .labelsHidden()
                    .frame(width: 150, height: 100, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .compositingGroup()
                }
                .onChange(of: min) { _ in
                    if min > max {
                        max = min
                    }
                }

                VStack {
                    Text("Edad Máxima").font(.headline)
                    Picker("Mín edad", selection: $max) {
                        ForEach(18 ..< 100, id: \.self) {
                            Text("\($0)")
                                .foregroundColor(.primary)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .labelsHidden()
                    .frame(width: 150, height: 100, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .compositingGroup()
                }.onChange(of: max) { _ in
                    if max < min {
                        min = max
                    }
                }
            }
        .frame(height: 150)
            .padding(.top)
    }


}
