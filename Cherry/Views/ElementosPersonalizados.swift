//
//  ElementosPersonalizados.swift
//  Cherry
//
//  Created by Aula11 on 9/11/21.
//

import SwiftUI
import SDWebImageSwiftUI
import CoreLocation

struct ElementosPersonalizados: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ElementosPersonalizados_Previews: PreviewProvider {
    static var previews: some View {
        ElementosPersonalizados()
    }
}

struct TextFieldPersonalizado: View{
    var placeholder: String
    @Binding var texto: String
    var sinAutocorrector = true
    var mayusculas = true
    var body: some View {
        
        TextField(placeholder, text: $texto)
            .disableAutocorrection(sinAutocorrector)
            .autocapitalization(mayusculas ? .words : .none)
            .padding()
            .background(.regularMaterial)
            .cornerRadius(RADIUS)
    }
}

struct TextEditorPersonalizado: View{
    @Binding var text: String
    
    init(text: Binding<String>) {
        self._text = text
        UITextView.appearance().backgroundColor = .clear
    }
    var body: some View {
        ZStack {
            TextEditor(text: $text)
                .font(.body)
                .foregroundColor(.primary) // Text color
                .background(.clear) // TextEditor's Background Color
        }
        .frame(height: 130)
        .padding(5)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: RADIUS))
        
    }
    
}

struct SecureFieldPersonalizado: View{
    var placeholder: String
    @Binding var texto: String
    @State var isSecured: Bool = true
    
    
    var body: some View {
        
        ZStack(alignment: .trailing) {
            if isSecured {
                SecureField(placeholder, text: $texto)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(RADIUS)
            } else {
                TextField(placeholder, text: $texto)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(RADIUS)
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


struct BotonPersonalizado: View{
    var texto: String
    var color: Color
    
    var body: some View {
        
        Text(texto)
            .foregroundColor(.white)
            .fontWeight(.bold)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(RADIUS)
        
    }
}


struct BotonSoloIconoPersonalizado: View{
    var icono: String
    var colorFondo: Color = GRAY
    var colorIcono: Color = .gray
    
    var body: some View {
        
        Image(systemName: icono)
            .font(.title)
            .foregroundColor(colorIcono)
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: RADIUS)
                    .fill(colorFondo))
        
    }
}


struct FotoCircular: View{
    var foto: Image
    var size: CGFloat
    var body: some View {
        foto
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            
    }
}

struct FotoMasRecomendado: View{
    var url: String
    var body: some View {
        WebImage(url: URL(string: url))
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenWidth * 0.9)
            .mask(Circle())
            .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
    }
}

struct WebFotoCircular: View{
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

struct TextNombre: View{
    var texto: String
    
    var body: some View {
        Text(texto)
            .semibold()
            .foregroundColor(.primary)
    }
}

struct TextTitulo: View{
    var texto: String
    
    var body: some View {
        Text(texto)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
}

struct botonFotoView: View {
    @State var mostrarImagePicker = false
    @Binding var foto: UIImage
    var url = ""
    
    var body: some View {
    Button(){
        mostrarImagePicker.toggle()
    }label:{
        if(url == ""){
            Image(uiImage: foto)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .background(Image(systemName: "camera.fill").foregroundColor(.primary))
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: RADIUS))
                .onAppear {
                    print("FOTO: \(url)")
                }
        }else{
            Image(uiImage: foto)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .background(Image(systemName: "camera.fill").foregroundColor(.primary))
                .background(WebImage(url: URL(string: url)).resizable()
                                .scaledToFill().opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: RADIUS))
                .onAppear {
                    print("FOTO: \(url)")
                }
        }
        
    }
    .sheet(isPresented: $mostrarImagePicker){
        ImagePicker(sourceType: .photoLibrary, selectedImage: $foto)
    }
}
}

struct FondoPersonalizado: View{
    @State var centro = UnitPoint(x: 0, y: 0)
    @State var x1 = 0.0
    @State var x2 = 0.0
    @State var x3 = 0.0
    @State var y1 = 0.0
    @State var y2 = 0.0
    @State var y3 = 0.0
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    let colors = [Color("FondoRosa"), Color("FondoAzul"), Color("FondoRosa"), Color("FondoAzul"), Color("FondoRosa"),]
    
    var body: some View {
        ZStack{
            AngularGradient(gradient: Gradient(colors: [Color("FondoAzul"), Color("FondoRosa"), Color("FondoAzul")]), center: centro)
            

            Circle().fill(Color("AccesorioAzul")).frame(width: 300, height: 300)
                .offset(x: 140 + x1, y: 240 + y1)
                .shadow(color: Color("AccesorioAzul"), radius: 20)
                
            Circle().fill(Color("AccesorioRosa")).frame(width: 200, height: 200)
                .offset(x: -140 + x2, y: -40 + y2)
                .shadow(color: Color("AccesorioRosa"), radius: 20)
            Circle().fill(Color("AccesorioMorado")).frame(width: 250, height: 250)
                .offset(x: 80 + x3, y: -300 + y3)
                .shadow(color: Color("AccesorioMorado"), radius: 20)
        }.ignoresSafeArea()
            .onReceive(timer, perform: { _ in
                withAnimation(.linear(duration: 6), {
                    
                    self.centro.x += CGFloat.random(in: -100...100)
                    self.centro.y += CGFloat.random(in: -100...100)
                    
                    self.x1 =  CGFloat.random(in: -50...50)
                    self.x2 =  CGFloat.random(in: -50...50)
                    self.x3 =  CGFloat.random(in: -50...50)
                    self.y1 =  CGFloat.random(in: -50...50)
                    self.y2 =  CGFloat.random(in: -50...50)
                    self.y3 =  CGFloat.random(in: -50...50)
                })
               
            })
    }
}


struct LogoLogin: View{
    
    var body: some View {
        Image( "Logo")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 180, height: 180)
            .opacity(OPACITY)
            .shadow(color: .white.opacity(0.6), radius: 20)
    }
}

func calcularEdad(fecha: Date) -> Int{
    var age: Int
    let cumple = Calendar.current.dateComponents([.year, .month, .day], from: fecha)
    let now = Calendar.current.dateComponents([.year, .month, .day], from: Date.now)
    let ageComponents = Calendar.current.dateComponents([.year], from: cumple, to: now)
    
    age = ageComponents.year!
    return age
}

struct AtributoView: View {
    var texto: String
    var icono: String = ""
    var coincide: Bool = false
    var body: some View {
        if(coincide){
            textoView
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: .black.opacity(0.07), radius: 3, x: -3, y: -3)
                .shadow(color: .black.opacity(0.07), radius: 3, x: 3, y: 3)
                .padding(5)
        }else{
            textoView
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: .black.opacity(0.07), radius: 3, x: -3, y: -3)
                .shadow(color: .black.opacity(0.07), radius: 3, x: 3, y: 3)
                .padding(5)
        }
        
    }
    
    var textoView: some View{
        HStack{
            if(icono != ""){
                Image(systemName: icono)
            }
            Text(texto)
                .foregroundColor(coincide ? .white : .primary)
        }
        .padding(10)
    }
}

struct SeccionTitulo: View{
    var texto: String
    
    init(_ texto: String){
        self.texto = texto
    }
    
    var body: some View{
        HStack{
            Text(texto)
                .fontWeight(.semibold)
            Spacer()
        }
    }
}

struct SemiTitulo: View{
    var texto: String
    
    init(_ texto: String){
        self.texto = texto
    }
    
    var body: some View{
        Text(texto)
            .font(.title)
            .fontWeight(.semibold)
    }
    
}

struct cuadroSobreMi: View {
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
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 3, x: -3, y: -3)
        .shadow(color: .black.opacity(0.07), radius: 3, x: 3, y: 3)
        .padding(.horizontal)
    }
}
