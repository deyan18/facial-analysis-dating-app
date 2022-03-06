//
//  EditarView.swift
//  Cherry
//
//  Created by deyan on 9/10/21.
//

import SwiftUI
import FirebaseFirestore
import Firebase

struct EditarView: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var vm: MainViewModel
    @EnvironmentObject var lm: LocationManager

    //Campos
    @State var nombre = ""
    @State var sobreMi = ""
    
    //Edad
    @State var fechaNacimiento: Date = Date()
    let fechaComienzo: Date = Calendar.current.date(from: DateComponents(year: 1920)) ?? Date()
    let fechaFinal: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
    
    //Generos
    var generos = ["Mujer", "Hombre", "No Binario"]
    @State private var genero = ""
    @State var generosBuscar: [GenderModel] = [GenderModel(gender: "Mujer"),
                                               GenderModel(gender: "Hombre"),
                                               GenderModel(gender: "No Binario")]
    @State var generosSeleccionados: [String] = []
    
    //Atributos
    @State var buscarAtributo = false
    @State var atributoBusqueda = ""
    @State var atributosSeleccionados: [String] = []

    //Fotos
    @State var foto1: UIImage = UIImage.init(named:"Vacio")!
    @State var foto2: UIImage = UIImage.init(named:"Vacio")!
    @State var foto3: UIImage = UIImage.init(named:"Vacio")!
    @State var fotoV: UIImage = UIImage.init(named:"Vacio")!
    @State var url1 = ""
    @State var url2 = ""
    @State var url3 = ""
    @State var urlV = ""
    var fotoEmpty: UIImage = UIImage.init(named:"Vacio")! //Para comparar si una foto se ha alterado

    //Alertas
    @State var fotoValida = false
    @State var faltanDatos = false
    @State var apiErrorGuardar = false
    @State var alertFoto = false
    
    var body: some View {
        ZStack{
                
            ScrollView(showsIndicators: false){
                VStack{ //Dividido en grupos porque no puede haber mas de 10 componentes en una view
                    Group{
                        editarNombre
                        Divider()
                        editarDescripcion
                        Divider()
                        edad
                        Divider()
                        generoPicker
                        Divider()
                    }
                    
                    generoBusco
                    Divider()
                    fotos
                    Divider()
                    fotoVerificar
                    Divider()
                    atributosField
                    Spacer().frame(height: 100) //Para que no quede tapado por la tabbar
                        
                }
                .padding()
                .navigationTitle("Editar Perfil")
                
            }.onTapGesture {
                hideKeyboard()
            }
            
            if vm.showLoadingView {
                Color.black.opacity(0.7).ignoresSafeArea()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: CARD_RADIUS, style: .continuous))
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    
            }
            
            Spacer()
                .alert(isPresented: $alertFoto) {
                    Alert(
                        title: Text("Foto No Válida"),
                        message: Text("La foto de cara no es válida. Vuelva a probar con otra.")
                    )
                }
            
            Spacer()
                .alert(isPresented: $apiErrorGuardar) {
                    Alert(
                        title: Text("Problema con servidor"),
                        message: Text("Vuelve a intentarlo más tarde.")
                    )
                }
            
                
        }
        
        
        .navigationBarItems(
            trailing:
                //Boton guardar
                Button(action: {
                    //Pasamos los datos de los attributes y los generos a sus arrays correspondientes
                    atributosSeleccionados.removeAll()
                    vm.attributes.forEach { a in
                        if(a.isSelected){
                            atributosSeleccionados.append(a.text)
                        }
                    }
                    
                    generosSeleccionados.removeAll()
                    generosBuscar.forEach { genero in
                        if(genero.isSelected){
                            generosSeleccionados.append(genero.gender)
                        }
                    }
                    
                    if(nombre == "" || sobreMi == "" || atributosSeleccionados.isEmpty || generosSeleccionados.isEmpty){
                        faltanDatos = true //Para acción la alerta
                    }else{
                        guardarDatos()
                    }
                        
                }, label: {
                    Text("Guardar")
                })
                .disabled(vm.showLoadingView)
                .alert(isPresented: $faltanDatos) {
                    Alert(
                        title: Text("Faltan datos"),
                        message: Text("Rellene todos los datos.")
                    )
                }
            
        )
        .onAppear(){
            cargarDatos()
        }
        .onChange(of: fotoV) { e in
            subirFotoTemp()
        }
    }
    
    var editarNombre: some View{
        VStack{
            SectionTitle("Nombre")
            TextFieldCustom(placeholder: "Nombre y Apellidos", text: $nombre)
        }.padding(.vertical)
    }
    
    var editarDescripcion: some View{
        VStack{
            SectionTitle("Sobre mi")
            TextEditorCustom(text: $sobreMi)
        }.padding(.vertical)
    }
    
    var edad: some View{
        VStack{
            SectionTitle("Edad")
            DatePicker("Fecha de Nacimiento", selection: $fechaNacimiento, in: fechaComienzo...fechaFinal, displayedComponents: [.date])
                
        }.padding(.vertical)
    }
    
    var generoPicker: some View{
        VStack{
            SectionTitle("Genero")
            Picker("Genero", selection: $genero) {
                ForEach(generos, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
        }.padding(.vertical)
    }
    
    var generoBusco: some View {
        VStack{
            SectionTitle("Busco")
            HStack(spacing: 20){
                ForEach(0..<generosBuscar.count){ index in
                    HStack {
                        Button(action: {
                            generosBuscar[index].isSelected.toggle()
                        }) {
                            HStack{
                                if generosBuscar[index].isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .animation(.easeIn)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.primary)
                                }
                                Text(generosBuscar[index].gender).foregroundColor(.primary)
                                    .font(.callout)
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.vertical, 2)
                }
            }
            
        }.padding(.vertical)
    }
    
    var fotos: some View {
        VStack{
            SectionTitle("Fotos")
            HStack(spacing: 20){
                UploadImageButton(image: $foto1, url: vm.currentUser?.url1 ?? "")
                UploadImageButton(image: $foto2, url: vm.currentUser?.url2 ?? "")
                UploadImageButton(image: $foto3, url: vm.currentUser?.url3 ?? "")
            }
            
        }.padding(.vertical)
    }
    
    var fotoVerificar: some View {
        HStack{
            VStack{
                SectionTitle("Foto de Cara")
                HStack{
                    Text("Esta foto no se mostrará en tu perfil.")
                        .font(.callout)
                    Spacer()
                }
            }
            Spacer()
            UploadImageButton(image: $fotoV, url: vm.currentUser?.urlV ?? "")
        }.padding()
            
    }
    
    var atributosField: some View{
        VStack{
            if(!buscarAtributo){
                //Lista con todos los attributes + boton de busqueda
                SectionTitle("Atributos Disponibles")
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        //Boton que activa el campo de busqueda
                        HStack{
                            Button {
                                withAnimation() {
                                    buscarAtributo.toggle()
                                }
                            } label: {
                                AttributeView(text: "Buscar", icon: "magnifyingglass.circle.fill")
                            }
                            
                        }
                        //Lista de todos los attributes
                        ForEach(vm.attributes.indices, id: \.self) { index in
                            if(!vm.attributes[index].isSelected){
                                Button {
                                    withAnimation() {
                                        vm.attributes[index].isSelected = true
                                    }
                                } label: {
                                    AttributeView(text: vm.attributes[index].text, icon: "plus.circle.fill")
                                        .foregroundColor(.primary)
                                    
                                }
                            }
                        }
                    }
                }
            }else{
                //Vista de busqueda de atributo
                Button {
                    withAnimation() {
                        buscarAtributo.toggle()
                    }
                } label: {
                    HStack{
                        Label("Volver", systemImage: "chevron.backward")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                //Campo de busqueda
                TextFieldCustom(placeholder: "Ej: Cantante", text: $atributoBusqueda)

                //Lista de resultados de la busqueda
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        ForEach(vm.attributes.indices, id: \.self) { index in
                            if(!vm.attributes[index].isSelected && vm.attributes[index].text.lowercased().contains(atributoBusqueda.lowercased())){
                                Button {
                                    withAnimation() {
                                        vm.attributes[index].isSelected = true
                                    }
                                } label: {
                                    AttributeView(text: vm.attributes[index].text, icon: "plus.circle.fill")
                                        .foregroundColor(.primary)
                                    
                                }
                            }
                        }
                    }
                }
            }
            
            //Lista de attributes seleccionados
            SectionTitle("Atributos Seleccionados")
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    ForEach(vm.attributes.indices, id: \.self) { index in
                        if(vm.attributes[index].isSelected){
                            Button {
                                withAnimation() {
                                    vm.attributes[index].isSelected = false
                                }
                            } label: {
                                AttributeView(text: vm.attributes[index].text, icon: "minus.circle.fill")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
        }.padding(.vertical)
    }
    
    //Funcion que se llama onAppear que rellena los campos con los datos de la BD
    func cargarDatos(){
        //Valor de campos de texto, picker de sexo y fecha nacimiento
        nombre = vm.currentUser?.name ?? ""
        sobreMi = vm.currentUser?.aboutMe ?? ""
        genero = vm.currentUser?.gender ?? ""
        fechaNacimiento = vm.currentUser?.birthDate ?? Date()

        url1 = vm.currentUser?.url1 ?? ""
        url2 = vm.currentUser?.url2 ?? ""
        url3 = vm.currentUser?.url3 ?? ""
        urlV = vm.currentUser?.urlV ?? ""
        
        //Lista de generos que busca
        vm.currentUser?.lookingFor.forEach({ generoGuardado in
            for (index,generoLista) in generosBuscar.enumerated() {
                if(generoLista.gender == generoGuardado){
                    generosBuscar[index].isSelected = true
                }
            }
        })
        
        //Limpiamos los attributes
        for (index, _) in vm.attributes.enumerated() {
           vm.attributes[index].isSelected = false
        }
        
        
        //Lista de attributes previamente seleccioandos
        vm.currentUser?.attributes.forEach({ atributo in
            for (index,atributosLista) in vm.attributes.enumerated() {
                if(atributo == atributosLista.text){
                    vm.attributes[index].isSelected = true
                }
            }
        })
        
    }
    
    private func subirFotoTemp(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{return}
        
        vm.showLoadingView = true
        let refFotoV = FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/fotoTemp")
        guard let fotoVData = fotoV.jpegData(compressionQuality: 0.8) else {return}
        refFotoV.putData(fotoVData, metadata: nil) {metadata, err in
            if let err = err {
                print("Error subiendo fotoTemp: \(err)")
                return
            }
            
            refFotoV.downloadURL { urlTemp, err in
                if let err = err {
                    print("Error descargando url fotoTemp: \(err)")
                    return
                }
                
                if let urlTemp = urlTemp{
                    print("Correcto url fotoTemp: \(urlTemp.absoluteString)")
                    
                    //Para comprobar que la foto es valida
                    validarFoto(url: urlTemp.absoluteString)
                }
                
            }}
    }
    
    private func guardarDatos(){
        vm.showLoadingView = true
        //Para las tareas asincronas
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "any-label-name")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        
        //Sacar el id del usuario
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{return}
        
        dispatchQueue.async {
            //Si se ha cambiado la foto1 se vuelve a subir a la BD
            if(foto1 != fotoEmpty){
                let refFoto1 = FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/foto1")
                guard let foto1Data = foto1.jpegData(compressionQuality: 0.8) else {return}
                
                dispatchGroup.enter()
                refFoto1.putData(foto1Data, metadata: nil) {metadata, err in
                    if let err = err {
                        print("Error subiendo foto1: \(err)")
                        return
                    }
                    
                    refFoto1.downloadURL { url1, err in
                        if let err = err {
                            print("Error descargando url foto1: \(err)")
                            return
                        }
                        
                        self.url1 = url1?.absoluteString ?? ""
                        
                        print("Correcto url foto1: \(url1?.absoluteString ?? "")")
                        dispatchSemaphore.signal()
                        dispatchGroup.leave()
                    }}
                dispatchSemaphore.wait()
            }
            
            //Si se ha cambiado la foto2 se vuelve a subir a la BD
            if(foto2 != fotoEmpty){
                let refFoto2 = FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/foto2")
                guard let foto2Data = foto2.jpegData(compressionQuality: 0.8) else {return}
                dispatchGroup.enter()
                refFoto2.putData(foto2Data, metadata: nil) {metadata, err in
                    if let err = err {
                        print("Error subiendo foto2: \(err)")
                        return
                    }
                    
                    refFoto2.downloadURL { url2, err in
                        if let err = err {
                            print("Error descargando url foto1: \(err)")
                            return
                        }
                        self.url2 = url2?.absoluteString ?? ""

                        print("Correcto url foto2: \(url2?.absoluteString ?? "")")
                        dispatchSemaphore.signal()
                        dispatchGroup.leave()
                    }}
                dispatchSemaphore.wait()
            }
            
            //Si se ha cambiado la foto3 se vuelve a subir a la BD
            if(foto3 != fotoEmpty){
                let refFoto3 = FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/foto3")
                guard let foto3Data = foto3.jpegData(compressionQuality: 0.8) else {return}
                dispatchGroup.enter()
                refFoto3.putData(foto3Data, metadata: nil) {metadata, err in
                    if let err = err {
                        print("Error subiendo foto3: \(err)")
                        return
                    }
                    
                    refFoto3.downloadURL { url3, err in
                        if let err = err {
                            print("Error descargando url foto3: \(err)")
                            return
                        }
                        
                        
                        self.url3 = url3?.absoluteString ?? ""
                        print("Correcto url foto3: \(url3?.absoluteString ?? "")")
                        dispatchSemaphore.signal()
                        dispatchGroup.leave()
                        
                    }}
                dispatchSemaphore.wait()
            }
            
            //Si se ha cambiado la fotoV y es valida se vuelve a subir a la BD
            if(fotoValida){
                
                let refFotoV = FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/fotoV")
                guard let fotoVData = fotoV.jpegData(compressionQuality: 0.8) else {return}
                dispatchGroup.enter()
                refFotoV.putData(fotoVData, metadata: nil) {metadata, err in
                    if let err = err {
                        print("Error subiendo fotoV: \(err)")
                        return
                    }
                    
                    refFotoV.downloadURL { urlV, err in
                        if let err = err {
                            print("Error descargando url fotoV: \(err)")
                            return
                        }
                        
                        
                        self.urlV = urlV?.absoluteString ?? ""
                        
                        print("Correcto url fotoV: \(urlV?.absoluteString ?? "")")
                        
                        dispatchSemaphore.signal()
                        dispatchGroup.leave()
                    }}
                dispatchSemaphore.wait()
            } else{
                DispatchQueue.main.async {
                    vm.showLoadingView = false
                }
            }
        }
        //Tras terminar de subir las fotos se pasa a subir el resto de datos
        dispatchGroup.notify(queue: dispatchQueue) {
            
            DispatchQueue.main.async {
                    var userData: [String : Any]
                    
                    userData = ["uid": uid,"nombre": nombre, "sobreMi": sobreMi, "genero": genero, "busco": generosSeleccionados, "url1": url1, "url2": url2, "url3": url3, "urlV": urlV, "fechaNacimiento": fechaNacimiento, "atributos": atributosSeleccionados, "ubicacion": GeoPoint(latitude: lm.lastLocation?.coordinate.latitude ?? 0.0, longitude: lm.lastLocation?.coordinate.longitude ?? 0.0)]
                    
                    //Se hace un update ya que hay datos que no se modifican aqui
                    FirebaseManager.shared.firestore.collection("usuarios")
                        .document(uid).updateData(userData) { err in
                            if let err = err{
                                print("Error guardar: \(err)")
                                return
                            }
                            
                            vm.showLoadingView = false
                            vm.fetchCurrentUser()
                            vm.analyzeUsers()
                        }

                }
                
        }
    }
    
    //Funcion que comprueba si se reconoce una cara en la url de la foto dada haciendo una llamada a la api con DeepFace
    func validarFoto(url: String) -> Void {
        let json = ["url": url]
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    
                    let url = NSURL(string: "\(vm.apiURL)/validarFoto/")!
                    let request = NSMutableURLRequest(url: url as URL)
                    request.httpMethod = "POST"
                    
                    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                    request.httpBody = jsonData
                    
                    let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                        if error != nil{
                            print("Error -> \(String(describing: error))")
                            //Para alerta
                            DispatchQueue.main.async {
                                apiErrorGuardar = true
                                vm.showLoadingView = false
                            }
                            return
                        }
                        do {
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(Bool.self, from: data!)
                            print("Result -> \(result)")

                            //Para alerta
                            DispatchQueue.main.async {
                                vm.showLoadingView = false
                                self.fotoValida = result
                                self.alertFoto = !self.fotoValida
                            }

                        } catch {
                            print("Error -> \(error)")
                        }
                    }
                    
                    task.resume()
                } catch {
                    DispatchQueue.main.async {
                        vm.showLoadingView = false
                        apiErrorGuardar = true
                    }
                    print(error)
                }
            }
    
}




