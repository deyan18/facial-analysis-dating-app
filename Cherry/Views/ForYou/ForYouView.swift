//
//  HomeView.swift
//  Cherry
//
//  Created by deyan on 26/9/21.
//

import CoreLocation
import SDWebImageSwiftUI
import SwiftUI

struct ForYouView: View {
    @EnvironmentObject var vm: MainViewModel
    @EnvironmentObject var lm: LocationManager

    @State var openProfileSheet: Bool = false
    @State var openChat = false // From profile sheet

    let columnsPhone: [GridItem] = [
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
    ]

    let columnsPad: [GridItem] = [
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil),
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // Opens chat from profile
                NavigationLink("", isActive: $openChat) {
                    ChatView()
                }

                navBar

                ScrollView(showsIndicators: false) {
                    VStack {
                        bestMatchProfile
                        profiles
                    }
                    .padding(.bottom, UIDevice.isIPhone ? 40 : 85)
                    .padding(.top, 70)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                vm.hideTabBar = false
                checkLocationUpdate()
            }
            .sheet(isPresented: $openProfileSheet, onDismiss: {
            }, content: {
                ProfileView(user: vm.selectedUser!, isSheet: true, showChatLikeButtons: true, openChat: $openChat)

            })
            .alert(isPresented: $vm.apiError) {
                Alert(
                    title: Text("Problema con servidor"),
                    message: Text("No se han podido ordenar las personas por rasgos faciales. Pulsa el logo para volver a intentarlo.")
                )
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }

    func checkLocationUpdate() {
        guard let savedLocation = vm.currentUser?.location else { return }
        guard let currentLocation = lm.lastLocation else { return }
        let distance = savedLocation.distance(from: currentLocation)

        if SHOW_DEBUG_CONSOLE {
            print("DISTANACE: \(distance)")
        }
        if distance > MAX_DISTANCE_UPDATE {
            vm.updateLocation(location: currentLocation)
            vm.analyzeUsers()
        }
    }

    var navBar: some View {
        VStack {
            HStack {
                ZStack {
                    logoButton
                    title
                    filtersButton
                }
                Spacer()
            }
            .padding(.horizontal)
            .background(.thinMaterial)
            Spacer()
        }.zIndex(1)
    }

    var logoButton: some View {
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

    var title: some View {
        HStack {
            if vm.showDebug {
                VStack {
                    Text("loc: \(vm.currentUser?.location.coordinate.longitude ?? -1.0):\(vm.currentUser?.location.coordinate.latitude ?? -1.0)")
                        .font(.caption)
                    Text("min: \(vm.currentUser?.ageMin ?? -1) max: \(vm.currentUser?.ageMax ?? -1) ")
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

    var filtersButton: some View {
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

    var bestMatchProfile: some View {
        ZStack {
            VStack {
                BigImageCircular(url: vm.usersAnalyzed.first?.url1 ?? "")
                    .onTapGesture {
                        vm.selectedUser = vm.usersAnalyzed.first
                        openProfileSheet.toggle()
                    }

                SemiBoldTitle(vm.usersAnalyzed.first?.name ?? "")

                if vm.showDebug {
                    Text("loc: \(vm.usersAnalyzed.first?.location.coordinate.longitude ?? -1.0):\(vm.usersAnalyzed.first?.location.coordinate.latitude ?? -1.0)")
                        .font(.caption)
                    Text("features: \(vm.usersAnalyzed.first?.distanceFeatures ?? -1.0)")
                        .font(.caption)
                }
            }
            if !vm.usersAnalyzed.isEmpty {
                bestMatchBadge
            }
        }
    }

    var bestMatchBadge: some View {
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

    var profiles: some View {
        LazyVGrid(columns: UIDevice.isIPhone ? columnsPhone : columnsPad) {
            ForEach(vm.usersAnalyzed, id: \.self) { usuario in
                if usuario.uid != vm.usersAnalyzed.first?.uid {
                    VStack {
                        ImageCircular(url: usuario.url1, size: 108)
                        SemiBoldText(texto: usuario.name)
                        if vm.showDebug {
                            Text("loc: \(usuario.location.coordinate.longitude):")
                                .font(.caption)
                            Text("\(usuario.location.coordinate.latitude)")
                                .font(.caption)
                            Text("features: \(usuario.distanceFeatures)")
                                .font(.caption)
                        }
                    }
                    .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                    .onTapGesture {
                        vm.selectedUser = usuario
                        openProfileSheet.toggle()
                    }
                }
            }
        }.padding(.horizontal)
    }
}
