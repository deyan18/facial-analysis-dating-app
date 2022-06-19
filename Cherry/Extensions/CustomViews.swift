//
//  ElementosPersonalizados.swift
//  Cherry
//
//  Created by Aula11 on 9/11/21.
//

import CoreLocation
import SDWebImageSwiftUI
import SwiftUI

struct TextFieldCustom: View {
    var placeholder: String
    @Binding var text: String
    var disableAutocorrection = true
    var autocap = true
    var body: some View {
        TextField(placeholder, text: $text)
            .disableAutocorrection(disableAutocorrection)
            .autocapitalization(autocap ? .words : .none)
            .padding()
            .background(.regularMaterial)
            .cornerRadius(BUTTON_TFIELD_RADIUS)
    }
}

struct TextEditorCustom: View {
    @Binding var text: String

    init(text: Binding<String>) {
        _text = text
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        ZStack {
            TextEditor(text: $text)
                .font(.body)
                .foregroundColor(.primary)
                .background(.clear)
        }
        .frame(height: 130)
        .padding(5)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BUTTON_TFIELD_RADIUS))
    }
}

struct SecureFieldCustom: View {
    var placeholder: String
    @Binding var text: String
    @State var isSecured: Bool = true

    var body: some View {
        ZStack(alignment: .trailing) {
            if isSecured {
                SecureField(placeholder, text: $text)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(BUTTON_TFIELD_RADIUS)
            } else {
                TextField(placeholder, text: $text)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(BUTTON_TFIELD_RADIUS)
            }
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(.gray)
                    .padding(.trailing, 10)
            }
        }
    }
}

struct ButtonCustom: View {
    var text: String
    var color: Color

    var body: some View {
        Text(text)
            .foregroundColor(.white)
            .fontWeight(.bold)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(BUTTON_TFIELD_RADIUS)
    }
}

struct IconButtonCustom: View {
    var icon: String
    var colorBG: Color = Color.secondarySystemBackground
    var colorIcon: Color = .gray

    var body: some View {
        Image(systemName: icon)
            .font(.title)
            .foregroundColor(colorIcon)
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: BUTTON_TFIELD_RADIUS)
                    .fill(colorBG))
    }
}

struct BigImageCircular: View {
    var url: String
    var body: some View {
        WebImage(url: URL(string: url))
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.screenWidth * (UIDevice.isIPhone ? 0.9 : 0.5) , height: UIScreen.screenWidth * (UIDevice.isIPhone ? 0.9 : 0.5))
            .mask(Circle())
            .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
    }
}

struct ImageCircular: View {
    var url: String
    var size: CGFloat
    var body: some View {
        WebImage(url: URL(string: url))
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
    }
}

struct SemiBoldText: View {
    var texto: String

    var body: some View {
        Text(texto)
            .semibold()
            .foregroundColor(.primary)
    }
}

struct TitleText: View {
    var texto: String

    var body: some View {
        Text(texto)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
}

struct UploadImageButton: View {
    @State var showImagePicker = false
    @Binding var image: UIImage
    var url = ""

    var body: some View {
        Button {
            showImagePicker.toggle()
        } label: {
            if url == "" {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .background(Image(systemName: "camera.fill").foregroundColor(.primary))
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: BUTTON_TFIELD_RADIUS))

            } else {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .background(Image(systemName: "camera.fill").foregroundColor(.primary))
                    .background(WebImage(url: URL(string: url)).resizable()
                        .scaledToFill().opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: BUTTON_TFIELD_RADIUS))
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
        }
    }
}

struct CustomBG: View {
    @State var center = UnitPoint(x: 0, y: 0)
    @State var x1 = 0.0
    @State var x2 = 0.0
    @State var x3 = 0.0
    @State var y1 = 0.0
    @State var y2 = 0.0
    @State var y3 = 0.0
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    let colors = [Color("FondoRosa"), Color("FondoAzul"), Color("FondoRosa"), Color("FondoAzul"), Color("FondoRosa")]

    var body: some View {
        ZStack {
            AngularGradient(gradient: Gradient(colors: [Color("FondoAzul"), Color("FondoRosa"), Color("FondoAzul")]), center: center)

            Circle().fill(Color("AccesorioAzul")).frame(width: UIDevice.isIPhone ? 300 : 400, height: UIDevice.isIPhone ? 300 : 400)
                .offset(x: (UIDevice.isIPhone ? 140 : 250) + x1, y: (UIDevice.isIPhone ? 240 : 300) + y1)
                .shadow(color: Color("AccesorioAzul"), radius: 20)

            Circle().fill(Color("AccesorioRosa")).frame(width: UIDevice.isIPhone ? 200 : 300, height: UIDevice.isIPhone ? 200 : 300)
                .offset(x: (UIDevice.isIPhone ? -140 : -250) + x2, y: (UIDevice.isIPhone ? -40 : -80) + y2)
                .shadow(color: Color("AccesorioRosa"), radius: 20)
            Circle().fill(Color("AccesorioMorado")).frame(width: UIDevice.isIPhone ? 250 : 350, height: UIDevice.isIPhone ? 250 : 350)
                .offset(x: (UIDevice.isIPhone ? 160 : 260) + x3, y: (UIDevice.isIPhone ? -300 : -340) + y3)
                .shadow(color: Color("AccesorioMorado"), radius: 20)
        }.ignoresSafeArea()
            .onReceive(timer, perform: { _ in
                withAnimation(.linear(duration: 6), {
                    self.center.x += CGFloat.random(in: -100 ... 100)
                    self.center.y += CGFloat.random(in: -100 ... 100)

                    self.x1 = CGFloat.random(in: -50 ... 50)
                    self.x2 = CGFloat.random(in: -50 ... 50)
                    self.x3 = CGFloat.random(in: -50 ... 50)
                    self.y1 = CGFloat.random(in: -50 ... 50)
                    self.y2 = CGFloat.random(in: -50 ... 50)
                    self.y3 = CGFloat.random(in: -50 ... 50)
                })

            })
    }
}

struct LogoSignIn: View {
    var body: some View {
        Image("Logo")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 180, height: 180)
            .opacity(ELEMENT_OPACITY)
            .shadow(color: .white.opacity(0.6), radius: 20)
    }
}

struct AttributeView: View {
    var text: String
    var icon: String = ""
    var matches: Bool = false
    var body: some View {
        if matches {
            textView
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: .black.opacity(0.07), radius: 3, x: -3, y: -3)
                .shadow(color: .black.opacity(0.07), radius: 3, x: 3, y: 3)
                .padding(5)
        } else {
            textView
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: .black.opacity(0.07), radius: 3, x: -3, y: -3)
                .shadow(color: .black.opacity(0.07), radius: 3, x: 3, y: 3)
                .padding(5)
        }
    }

    var textView: some View {
        HStack {
            if icon != "" {
                Image(systemName: icon)
            }
            Text(text)
                .foregroundColor(matches ? .white : .primary)
        }
        .padding(10)
    }
}

struct SectionTitle: View {
    var texto: String

    init(_ texto: String) {
        self.texto = texto
    }

    var body: some View {
        HStack {
            Text(texto)
                .fontWeight(.semibold)
            Spacer()
        }
    }
}

struct SemiBoldTitle: View {
    var texto: String

    init(_ texto: String) {
        self.texto = texto
    }

    var body: some View {
        Text(texto)
            .font(.title)
            .fontWeight(.semibold)
    }
}

struct AboutMeView: View {
    var heading: String
    var text: String

    var body: some View {
        VStack {
            HStack {
                Text(heading)
                    .font(.headline)
            }
            Divider()

            HStack {
                Text(text)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: UIScreen.screenWidth * (UIDevice.isIPhone ? 0.8 : 0.6))
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 3, x: -3, y: -3)
        .shadow(color: .black.opacity(0.07), radius: 3, x: 3, y: 3)
        .padding(.horizontal)
    }
}

struct TabBarCustom: View {
    @EnvironmentObject var vm: MainViewModel

    var tabBarElements = [TabBarElement(index: 0, text: "Para Ti", iconNormal: "house", iconSelected: "house.fill"),
                           TabBarElement(index: 1, text: "Chats", iconNormal: "message", iconSelected: "message.fill"),
                           TabBarElement(index: 2, text: "Perfil", iconNormal: "person", iconSelected: "person.fill")]

    var body: some View {
        HStack {
            Spacer()
            ForEach(tabBarElements, id: \.self) { element in
                Button {
                        vm.tabbarIndex = element.index
                } label: {
                    VStack {
                        if vm.tabbarIndex != element.index {
                            tabBarIcon(nombreIcono: element.iconNormal)
                        } else {
                            ZStack{
                                Circle().fill(Color.accentColor)
                                    .blur(radius: 10)
                                tabBarIcon(nombreIcono: element.iconSelected)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: BUTTON_TFIELD_RADIUS)
                                            .fill(Color.accentColor)
                                            .frame(width: 13, height: 5)
                                            .frame(maxHeight: .infinity, alignment: .top)
                                            .offset(y: UIDevice.isIPhone ? -6 : -12)
                                    )
                            }.frame(width: 30)
                        }
                        tabBarText(nombre: element.text)
                    }.padding(.bottom, 4)
                        
                }
                Spacer()
            }
        }
        .padding(EdgeInsets(top: 15, leading: 0, bottom: 20, trailing: 0))
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight * 0.08)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: BUTTON_TFIELD_RADIUS, style: .continuous))
    }
}


struct tabBarIcon: View {
    var nombreIcono: String

    var body: some View {
        Image(systemName: nombreIcono)
            .resizable()
            .frame(width: 24, height: 22)
            .foregroundColor(Color.primary.opacity(ELEMENT_OPACITY))
            
    }
}

struct tabBarText: View {
    var nombre: String

    var body: some View {
        Text(nombre)
            .font(.caption)
            .foregroundColor(Color.primary.opacity(ELEMENT_OPACITY))
    }
}

struct TabBarElement: Hashable {
    var index: Int
    var text: String
    var iconNormal: String
    var iconSelected: String
}

