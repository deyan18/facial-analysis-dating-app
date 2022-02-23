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
    @State var generosBuscar: [GeneroModel] = [GeneroModel(name: "Mujer"),
                                               GeneroModel(name: "Hombre"),
                                               GeneroModel(name: "No Binario")]
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
    @State var fotoNoEsValida = false
    @State var faltanDatos = false
    @State var apiErrorGuardar = false

    
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
                
            }
            
            if vm.loadingView {
                Color.black.opacity(0.7).ignoresSafeArea()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: RADIUSCARDS, style: .continuous))
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    
            }
            
            Spacer()
                .alert(isPresented: $fotoNoEsValida) {
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
                    //Pasamos los datos de los atributos y los generos a sus arrays correspondientes
                    atributosSeleccionados.removeAll()
                    vm.atributos.forEach { a in
                        if(a.esSeleccionado){
                            atributosSeleccionados.append(a.texto)
                        }
                    }
                    
                    generosSeleccionados.removeAll()
                    generosBuscar.forEach { genero in
                        if(genero.isSelected){
                            generosSeleccionados.append(genero.name)
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
                .disabled(vm.loadingView)
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
    }
    
    var editarNombre: some View{
        VStack{
            SeccionTitulo("Nombre")
            TextFieldPersonalizado(placeholder: "Nombre y Apellidos", texto: $nombre)
        }.padding(.vertical)
    }
    
    var editarDescripcion: some View{
        VStack{
            SeccionTitulo("Sobre mi")
            TextEditorPersonalizado(text: $sobreMi)
        }.padding(.vertical)
    }
    
    var edad: some View{
        VStack{
            SeccionTitulo("Edad")
            DatePicker("Fecha de Nacimiento", selection: $fechaNacimiento, in: fechaComienzo...fechaFinal, displayedComponents: [.date])
        }.padding(.vertical)
    }
    
    var generoPicker: some View{
        VStack{
            SeccionTitulo("Genero")
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
            SeccionTitulo("Busco")
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
                                Text(generosBuscar[index].name).foregroundColor(.primary)
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
            SeccionTitulo("Fotos")
            HStack(spacing: 20){
                botonFotoView(foto: $foto1, url: vm.usuarioPrincipal?.url1 ?? "")
                botonFotoView(foto: $foto2, url: vm.usuarioPrincipal?.url2 ?? "")
                botonFotoView(foto: $foto3, url: vm.usuarioPrincipal?.url3 ?? "")
            }
        }.padding(.vertical)
    }
    
    var fotoVerificar: some View {
        HStack{
            VStack{
                SeccionTitulo("Foto de Cara")
                HStack{
                    Text("Esta foto no se mostrará en tu perfil.")
                        .font(.callout)
                    Spacer()
                }
            }
            Spacer()
            botonFotoView(foto: $fotoV, url: vm.usuarioPrincipal?.urlV ?? "")
        }.padding()
            
    }
    
    var atributosField: some View{
        VStack{
            if(!buscarAtributo){
                //Lista con todos los atributos + boton de busqueda
                SeccionTitulo("Atributos Disponibles")
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        //Boton que activa el campo de busqueda
                        HStack{
                            Button {
                                withAnimation() {
                                    buscarAtributo.toggle()
                                }
                            } label: {
                                AtributoView(texto: "Buscar", icono: "magnifyingglass.circle.fill")
                            }
                            
                        }
                        //Lista de todos los atributos
                        ForEach(vm.atributos.indices, id: \.self) { index in
                            if(!vm.atributos[index].esSeleccionado){
                                Button {
                                    withAnimation() {
                                        vm.atributos[index].esSeleccionado = true
                                    }
                                } label: {
                                    AtributoView(texto: vm.atributos[index].texto, icono: "plus.circle.fill")
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
                TextFieldPersonalizado(placeholder: "Ej: Cantante", texto: $atributoBusqueda)

                //Lista de resultados de la busqueda
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        ForEach(vm.atributos.indices, id: \.self) { index in
                            if(!vm.atributos[index].esSeleccionado && vm.atributos[index].texto.lowercased().contains(atributoBusqueda.lowercased())){
                                Button {
                                    withAnimation() {
                                        vm.atributos[index].esSeleccionado = true
                                    }
                                } label: {
                                    AtributoView(texto: vm.atributos[index].texto, icono: "plus.circle.fill")
                                        .foregroundColor(.primary)
                                    
                                }
                            }
                        }
                    }
                }
            }
            
            //Lista de atributos seleccionados
            SeccionTitulo("Atributos Seleccionados")
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    ForEach(vm.atributos.indices, id: \.self) { index in
                        if(vm.atributos[index].esSeleccionado){
                            Button {
                                withAnimation() {
                                    vm.atributos[index].esSeleccionado = false
                                }
                            } label: {
                                AtributoView(texto: vm.atributos[index].texto, icono: "minus.circle.fill")
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
        vm.fetchAtributos()
        //Valor de campos de texto, picker de sexo y fecha nacimiento
        nombre = vm.usuarioPrincipal?.nombre ?? ""
        sobreMi = vm.usuarioPrincipal?.sobreMi ?? ""
        genero = vm.usuarioPrincipal?.genero ?? ""
        fechaNacimiento = vm.usuarioPrincipal?.fechaNacimiento ?? Date()

        url1 = vm.usuarioPrincipal?.url1 ?? ""
        url2 = vm.usuarioPrincipal?.url2 ?? ""
        url3 = vm.usuarioPrincipal?.url3 ?? ""
        urlV = vm.usuarioPrincipal?.urlV ?? ""
        
        //Lista de generos que busca
        vm.usuarioPrincipal?.busco.forEach({ generoGuardado in
            for (index,generoLista) in generosBuscar.enumerated() {
                if(generoLista.name == generoGuardado){
                    generosBuscar[index].isSelected = true
                }
            }
        })
        
        
        //Lista de atributos previamente seleccioandos
        vm.usuarioPrincipal?.atributos.forEach({ atributo in
            for (index,atributosLista) in vm.atributos.enumerated() {
                if(atributo == atributosLista.texto){
                    vm.atributos[index].esSeleccionado = true
                }
            }
        })
        
    }
    
    private func guardarDatos(){
        vm.loadingView = true
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
            
            //Si se ha cambiado la fotoV se vuelve a subir a la BD
            //Ademas se comprueba si la foto es valida usando DeepFace
            if(fotoV != fotoEmpty){
                
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
                        
                        //Para comprobar que la foto es valida
                        validarFoto(url: self.urlV)
                        
                        dispatchSemaphore.signal()
                        dispatchGroup.leave()
                    }}
                dispatchSemaphore.wait()
            } else{
                DispatchQueue.main.async {
                    vm.loadingView = false
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
                            
                            vm.fetchUsuarioActual()
                        }

                }
                
        }
    }
    
    //Funcion que comprueba si se reconoce una cara en la url de la foto dada haciendo una llamada a la api con DeepFace
    func validarFoto(url: String) -> Void {
        let json = ["url": url]
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    
                    let url = NSURL(string: "\(URLAPI)/validarFoto/")!
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
                                vm.loadingView = false
                            }
                            return
                        }
                        do {
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(Bool.self, from: data!)
                            print("Result -> \(result)")

                            //Para alerta
                            DispatchQueue.main.async {
                                vm.loadingView = false
                                self.fotoNoEsValida = !result
                            }

                        } catch {
                            print("Error -> \(error)")
                        }
                    }
                    
                    task.resume()
                } catch {
                    print(error)
                }
            }
    
}




