//
//  PerfilView.swift
//  Cherry
//
//  Created by deyan on 26/9/21.
//

import SDWebImageSwiftUI
import SwiftUI
import WrappingStack

struct ProfileView: View {
    @StateObject var chatVM: ChatViewModel = ChatViewModel()
    @EnvironmentObject var vm: MainViewModel
    @Environment(\.presentationMode) var presentationMode

    var user: UserModel
    var isSheet: Bool
    var showChatLikeButtons: Bool
    @Binding var openChat: Bool // To open chat in another view

    var body: some View {
        ScrollView(showsIndicators: false) {
            if isSheet {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.regularMaterial)
                    .frame(width: 50, height: 8)
                    .padding(.top)
            }

            ZStack {
                photos

                if isSheet {
                    closeButton
                }
            }.frame(width: UIScreen.screenWidth * (UIDevice.isIPhone ? 1 : 0.7), height: UIScreen.screenWidth * (UIDevice.isIPhone ? 1 : 0.7))

            nameAgeGender

            if showChatLikeButtons {
                chatLikeButtons
            }
            AboutMeView(heading: "Sobre mi", text: user.aboutMe)
            attributes
            Spacer()
                .frame(height: UIDevice.isIPhone ? 40 : 60)
        }.onAppear {
            onStart()
        }
    }

    private func onStart() {
        if vm.selectedUser != nil {
            chatVM.selectedUser = vm.selectedUser
        }
        chatVM.currentUser = vm.currentUser
    }

    var photos: some View {
        TabView {
            ForEach(user.urls, id: \.self) { url in
                VStack {
                    WebImage(url: URL(string: url))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.screenWidth * (UIDevice.isIPhone ? 0.9 : 0.6), height: UIScreen.screenWidth * (UIDevice.isIPhone ? 0.9 : 0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
    }

    var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 13, height: 13)
                    .padding(14)
                    .background(.thinMaterial, in: Circle())
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
            }

            Spacer()
        }.padding(UIDevice.isIPhone ? 30 : 50)
    }

    var nameAgeGender: some View {
        HStack {
            Text(user.name)
                .font(.title)
                .fontWeight(.semibold)
            Text("\(user.age)")
                .font(.title2)
            AttributeView(text: user.gender)
        }
    }

    var chatLikeButtons: some View {
        HStack(spacing: 20.0) {
            // Like button
            Button {
                chatVM.sendMessage(text: "*like*", date: Date.now)
                openChat = true
                presentationMode.dismiss()
            } label: {
                IconButtonCustom(icon: "heart.fill", colorIcon: Color.accentColor)
            }

            // Chat button
            Button {
                openChat = true
                presentationMode.dismiss()
            } label: {
                IconButtonCustom(icon: "message.fill", colorIcon: Color.gray)
            }
        }
        .padding(.bottom)
        .shadow(color: .black.opacity(0.07), radius: 3, x: -3, y: -3)
        .shadow(color: .black.opacity(0.07), radius: 3, x: 3, y: 3)
    }

    var attributes: some View {
        WrappingHStack(id: \.self, horizontalSpacing: 6) {
            ForEach(user.attributes, id: \.self) { a in
                AttributeView(text: a, matches: checkAttributeMatch(texto: a))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40) // Para que no lo tape la tabbar
    }

    private func checkAttributeMatch(texto: String) -> Bool {
        if !isSheet { return false }

        for atributo in vm.currentUser!.attributes {
            if atributo == texto {
                return true
            }
        }

        return false
    }
}
