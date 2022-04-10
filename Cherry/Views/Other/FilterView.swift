//
//  FiltroView.swift
//  Cherry
//
//  Created by Deyan on 6/2/22.
//

import SwiftUI

struct FilterView: View {
    @EnvironmentObject var vm: MainViewModel

    @State var ageMinLocal = 0
    @State var ageMaxLocal = 0

    @State private var featuresPrefence = "Similares"
    var features = ["Similares", "Diferentes"]

    var body: some View {
        Color.black.opacity(0.4).ignoresSafeArea()
        VStack {
            ZStack {
                closeButton
                SemiBoldTitle("Filtros")
            }

            Divider()
            chooseFeatures
            Divider()
            chooseAgeRange
            saveButton
        }
        .frame(width: UIScreen.screenWidth * (UIDevice.isIPhone ? 1 : 0.6))
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: CARD_RADIUS, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
        .padding()
        .onAppear {
            onStart()
        }
    }

    private func onStart() {
        if vm.currentUser?.wantsSimilar ?? true {
            featuresPrefence = "Similares"
        } else {
            featuresPrefence = "Diferentes"
        }
        ageMinLocal = vm.currentUser?.ageMin ?? 18
        ageMaxLocal = vm.currentUser?.ageMax ?? 99
    }

    private func saveChanges() {
        if featuresPrefence == "Similares" {
            vm.currentUser?.wantsSimilar = true
        } else {
            vm.currentUser?.wantsSimilar = false
        }
        vm.currentUser?.ageMin = ageMinLocal
        vm.currentUser?.ageMax = ageMaxLocal
        vm.updateAgeRange()
        vm.updateFeaturesPreference()
        vm.analyzeUsers()
    }

    var saveButton: some View {
        Button {
            saveChanges()
            withAnimation {
                vm.openFilters = false
            }
        } label: {
            ButtonCustom(text: "Guardar", color: .accentColor)
        }
    }

    var closeButton: some View {
        HStack {
            Spacer()
            Button {
                withAnimation {
                    vm.openFilters = false
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

    var chooseFeatures: some View {
        VStack {
            HStack {
                Text("Rasgos")
                    .font(.headline)
                Spacer()
            }
            Picker("Rasgos", selection: $featuresPrefence) {
                ForEach(features, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
        }.padding(.vertical)
    }

    var chooseAgeRange: some View {
        HStack {
            VStack {
                Text("Edad Mínima").font(.headline)
                Picker("Mín edad", selection: $ageMinLocal) {
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
            .onChange(of: ageMinLocal) { _ in
                if ageMinLocal > ageMaxLocal {
                    ageMaxLocal = ageMinLocal
                }
            }

            VStack {
                Text("Edad Máxima").font(.headline)
                Picker("Mín edad", selection: $ageMaxLocal) {
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
            }.onChange(of: ageMaxLocal) { _ in
                if ageMaxLocal < ageMinLocal {
                    ageMinLocal = ageMaxLocal
                }
            }
        }
        .frame(height: 150)
        .padding(.top)
    }
}
