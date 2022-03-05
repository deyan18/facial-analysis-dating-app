//
//  CrearPerfilView.swift
//  Cherry
//
//  Created by Deyan on 14/1/22.
//

import Firebase
import FirebaseFirestore
import SwiftUI

struct CrearPerfilView: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @EnvironmentObject var vm: MainViewModel
    @EnvironmentObject var lm: LocationManager

    // Campos
    @State var nombre = ""
    @State var sobreMi = ""

    // Genero propio
    @State private var generoSeleccionado = "Mujer"
    var generos = ["Mujer", "Hombre", "No Binario"]

    // Genero busca
    @State var generosBuscar: [GeneroModel] = [GeneroModel(name: "Mujer"),
                                               GeneroModel(name: "Hombre"),
                                               GeneroModel(name: "No Binario")]
    @State var generosBuscarSeleccionados: [String] = []

    // Edad
    @State var fechaNacimiento: Date = Date()
    // Limites del calendario
    let fechaComienzo: Date = Calendar.current.date(from: DateComponents(year: 1920)) ?? Date()
    let fechaFinal: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date())!

    // Fotos
    @State var foto1: UIImage = UIImage(named: "Vacio")!
    @State var foto2: UIImage = UIImage(named: "Vacio")!
    @State var foto3: UIImage = UIImage(named: "Vacio")!
    @State var fotoV: UIImage = UIImage(named: "Vacio")!
    @State var url1 = ""
    @State var url2 = ""
    @State var url3 = ""
    @State var urlV = ""
    var fotoEmpty: UIImage = UIImage(named: "Vacio")! // Para comparar si una foto se ha alterado

    // Atributos
    @State var buscarAtributo = false
    @State var atributoBusqueda = ""
    @State var atributosSeleccionados: [String] = []

    // Alertas
    @State var alertFotoNoValida = false
    @State var alertFaltanDatos = false
    @State var apiErrorGuardar = false

    // Cambio de vista
    @State var iniciarSesion = false

    var body: some View {
        ZStack{
        ScrollView(showsIndicators: false) {
            VStack {
                header
                Group {
                    editarNombre
                    Divider()
                    editarDescripcion
                    Divider()
                    edad
                    Divider()
                }
                Group {
                    generoPicker
                    Divider()
                    generoBusco
                    Divider()
                    fotos
                    Divider()
                    fotoVerificar
                }
                Divider()
                atributosField
                Divider()
                botonGuardar
            }
            .padding()
        }
        .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.85)
        .background(.ultraThinMaterial)
        .mask(RoundedRectangle(cornerRadius: RADIUSCARDS, style: .continuous))
        .onTapGesture {
            hideKeyboard()
        }
        .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
        // Cuando todo se ha completado correctamente iniciamos sesion
        .onChange(of: iniciarSesion) { _ in
            if iniciarSesion {
                vm.fetchUsuarioActual()
                vm.usuarioLoggedIn = true
            }
        }
        .onAppear{
            withAnimation {
                vm.mostrarBotonInfo = false
            }
        }
            
            if vm.loadingView {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
            }
            
            Spacer()
                .alert(isPresented: $apiErrorGuardar) {
                    Alert(
                        title: Text("Problema con servidor"),
                        message: Text("Vuelve a intentarlo más tarde.")
                    )
                }
        }
    }

    var header: some View {
        VStack {
            LogoLogin()
            TextTitulo(texto: "Personaliza tu perfil")
                .padding(.bottom, 20)
        }.alert(isPresented: $alertFaltanDatos) {
            Alert(
                title: Text("Faltan Datos"),
                message: Text("Asegurese que todos los campos están rellenos")
            )
        }
    }

    // Picker para elegir el genero propio
    var generoBusco: some View {
        VStack {
            SeccionTitulo("Busco")
            HStack(spacing: 20) {
                ForEach(0 ..< generosBuscar.count) { index in
                    HStack {
                        Button(action: {
                            generosBuscar[index].isSelected.toggle()
                        }) {
                            HStack {
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
                        }.buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.vertical, 2)
                }
            }
        }.padding(.vertical)
    }

    var fotos: some View {
        VStack {
            SeccionTitulo("Fotos")
            HStack {
                botonFotoView(foto: $foto1)
                Spacer()
                botonFotoView(foto: $foto2)
                Spacer()
                botonFotoView(foto: $foto3)
            }
        }.padding(.vertical)
    }

    var fotoVerificar: some View {
        HStack {
            VStack {
                SeccionTitulo("Foto de cara")
                HStack {
                    Text("Esta foto no se mostrará en tu perfil.")
                        .font(.callout)
                    Spacer()
                }.alert(isPresented: $alertFotoNoValida) {
                    Alert(
                        title: Text("Foto No Válida"),
                        message: Text("La foto de cara no es válida. Vuelva a probar con otra.")
                    )
                }
            }
            Spacer()
            botonFotoView(foto: $fotoV)
                

        }.padding(.vertical)
        
    }

    var editarNombre: some View {
        VStack {
            TextFieldPersonalizado(placeholder: "Nombre y Apellidos", texto: $nombre)
        }.padding(.vertical)
    }

    var editarDescripcion: some View {
        VStack {
            SeccionTitulo("Sobre Mi")
            TextEditorPersonalizado(text: $sobreMi)
        }.padding(.vertical)
    }

    var edad: some View {
        VStack {
            SeccionTitulo("Edad")
            DatePicker("Fecha de Nacimiento", selection: $fechaNacimiento, in: fechaComienzo ... fechaFinal, displayedComponents: [.date])
        }.padding(.vertical)
    }

    var generoPicker: some View {
        VStack {
            SeccionTitulo("Mi Genero")
            Picker("Genero", selection: $generoSeleccionado) {
                ForEach(generos, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
        }.padding(.vertical)
    }

    var atributosField: some View {
        VStack {
            if !buscarAtributo {
                SeccionTitulo("Atributos Disponibles")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        HStack {
                            Button {
                                withAnimation {
                                    buscarAtributo.toggle()
                                }
                            } label: {
                                AtributoView(texto: "Buscar", icono: "magnifyingglass.circle.fill")
                            }
                        }
                        ForEach(vm.atributos.indices, id: \.self) { index in
                            if !vm.atributos[index].esSeleccionado {
                                Button {
                                    withAnimation {
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
            } else {
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
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(vm.atributos.indices, id: \.self) { index in
                            if !vm.atributos[index].esSeleccionado && vm.atributos[index].texto.lowercased().contains(atributoBusqueda.lowercased()) {
                                Button {
                                    withAnimation {
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
            SeccionTitulo("Atributos Seleccionados")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(vm.atributos.indices, id: \.self) { index in
                        if vm.atributos[index].esSeleccionado {
                            Button {
                                withAnimation {
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

    var botonGuardar: some View {
        Button {
            // Pasamos los datos de los atributos y los generos a sus arrays correspondientes
            atributosSeleccionados.removeAll()
            vm.atributos.forEach { a in
                if a.esSeleccionado {
                    atributosSeleccionados.append(a.texto)
                }
            }

            generosBuscarSeleccionados.removeAll()
            generosBuscar.forEach { g in
                if g.isSelected {
                    generosBuscarSeleccionados.append(g.name)
                }
            }

            if (nombre == "" || sobreMi == "" || atributosSeleccionados.isEmpty || generosBuscarSeleccionados.isEmpty || foto1 == fotoEmpty || foto2 == fotoEmpty || foto3 == fotoEmpty || fotoV == fotoEmpty) {
                alertFaltanDatos = true
            } else {
                vm.loadingView = true
                guardarDatos()
            }

        } label: {
            BotonPersonalizado(texto: "Guardar", color: Color.accentColor)
                .padding(.top, 20)
        }
        
    }

    private func guardarDatos() {
        // Usamos dispatch para asegurarnos que las fotos se han subido antes de guardar el resto de los daots
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "any-label-name")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        // Sacar el id del usuario
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }

        // Path de las fotos
        let refFoto1 = FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/foto1")
        guard let foto1Data = foto1.jpegData(compressionQuality: 0.8) else { return }
        let refFoto2 = FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/foto2")
        guard let foto2Data = foto2.jpegData(compressionQuality: 0.8) else { return }
        let refFoto3 = FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/foto3")
        guard let foto3Data = foto3.jpegData(compressionQuality: 0.8) else { return }
        let refFotoV = FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/fotoV")
        guard let fotoVData = fotoV.jpegData(compressionQuality: 0.8) else { return }

        dispatchQueue.async {
            dispatchGroup.enter()
            refFoto1.putData(foto1Data, metadata: nil) { _, err in
                if let err = err {
                    if DEBUGCONSOLE {
                        print("Error subiendo foto1: \(err)")
                    }
                    return
                }

                refFoto1.downloadURL { url1, err in
                    if let err = err {
                        if DEBUGCONSOLE {
                            print("Error descargando url foto1: \(err)")
                        }
                        return
                    }

                    self.url1 = url1?.absoluteString ?? ""

                    if DEBUGCONSOLE {
                        print("Correcto url foto1: \(url1?.absoluteString ?? "")")
                    }
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                }
            }
            dispatchSemaphore.wait()

            dispatchGroup.enter()
            refFoto2.putData(foto2Data, metadata: nil) { _, err in
                if let err = err {
                    if DEBUGCONSOLE {
                        print("Error subiendo foto2: \(err)")
                    }
                    return
                }

                refFoto2.downloadURL { url2, err in
                    if let err = err {
                        if DEBUGCONSOLE {
                            print("Error descargando url foto1: \(err)")
                        }
                        return
                    }

                    self.url2 = url2?.absoluteString ?? ""

                    if DEBUGCONSOLE {
                        print("Correcto url foto2: \(url2?.absoluteString ?? "")")
                    }
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                }
            }
            dispatchSemaphore.wait()

            dispatchGroup.enter()
            refFoto3.putData(foto3Data, metadata: nil) { _, err in
                if let err = err {
                    if DEBUGCONSOLE {
                        print("Error subiendo foto3: \(err)")
                    }
                    return
                }

                refFoto3.downloadURL { url3, err in
                    if let err = err {
                        if DEBUGCONSOLE {
                            print("Error descargando url foto3: \(err)")
                        }
                        return
                    }

                    self.url3 = url3?.absoluteString ?? ""
                    if DEBUGCONSOLE {
                        print("Correcto url foto3: \(url3?.absoluteString ?? "")")
                    }
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                }
            }
            dispatchSemaphore.wait()

            dispatchGroup.enter()
            refFotoV.putData(fotoVData, metadata: nil) { _, err in
                if let err = err {
                    if DEBUGCONSOLE {
                        print("Error subiendo fotoV: \(err)")
                    }
                    return
                }

                refFotoV.downloadURL { urlV, err in
                    if let err = err {
                        if DEBUGCONSOLE {
                            print("Error descargando url fotoV: \(err)")
                        }
                        return
                    }

                    self.urlV = urlV?.absoluteString ?? ""

                    validarFoto(url: self.urlV)

                    if DEBUGCONSOLE {
                        print("Correcto url fotoV: \(urlV?.absoluteString ?? "")")
                    }
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                }
            }
            dispatchSemaphore.wait()
        }

        dispatchGroup.notify(queue: dispatchQueue) {
            DispatchQueue.main.async {
                var userData: [String: Any]

                userData = ["uid": uid, "nombre": nombre, "sobreMi": sobreMi, "genero": generoSeleccionado, "busco": generosBuscarSeleccionados, "url1": url1, "url2": url2, "url3": url3, "urlV": urlV, "fechaNacimiento": fechaNacimiento, "atributos": atributosSeleccionados, "ubicacion": GeoPoint(latitude: lm.lastLocation?.coordinate.latitude ?? 0.0, longitude: lm.lastLocation?.coordinate.longitude ?? 0.0)]

                FirebaseManager.shared.firestore.collection("usuarios")
                    .document(uid).setData(userData) { err in
                        if let err = err {
                            if DEBUGCONSOLE {
                                print("Error guardar: \(err)")
                            }
                            vm.loadingView = false
                            return
                        }
                        vm.loadingView = false
                        //vm.fetchUsuarioActual()
                    }
            }
        }
    }

    func validarFoto(url: String) {
        let json = ["url": url]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)

            let url = NSURL(string: "\(URLAPI)/validarFoto/")!
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"

            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, error in
                if error != nil {
                    DispatchQueue.main.async {
                        apiErrorGuardar = true
                        vm.loadingView = false
                    }
                    if DEBUGCONSOLE {
                        print("Error -> \(error)")
                    }
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(Bool.self, from: data!)
                    self.alertFotoNoValida = !result
                    self.iniciarSesion = result
                    if DEBUGCONSOLE {
                        print("Result -> \(result)")
                    }

                } catch {
                    if DEBUGCONSOLE {
                        print("Error -> \(error)")
                    }
                }
            }

            task.resume()
        } catch {
            if DEBUGCONSOLE {
                print(error)
            }
        }
    }
}
