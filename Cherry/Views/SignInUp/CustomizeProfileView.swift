//
//  CrearPerfilView.swift
//  Cherry
//
//  Created by Deyan on 14/1/22.
//

import Firebase
import FirebaseFirestore
import SwiftUI

struct CustomizeProfileView: View {
    @EnvironmentObject var vm: MainViewModel
    @EnvironmentObject var lm: LocationManager

    @State var name = ""
    @State var aboutMe = ""

    // Genders
    @State private var selectedGender = "Mujer"
    var genders = ["Mujer", "Hombre", "No Binario"]

    @State var lookingForOptions: [GenderModel] = [GenderModel(gender: "Mujer"),
                                               GenderModel(gender: "Hombre"),
                                               GenderModel(gender: "No Binario")]
    @State var lookingFor: [String] = []

    // Age
    @State var birthDate: Date = Date()
    let calendarStart: Date = Calendar.current.date(from: DateComponents(year: 1920)) ?? Date()
    let calendarEnd: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date())!

    // Fotos
    @State var img1: UIImage = UIImage(named: "Vacio")!
    @State var img2: UIImage = UIImage(named: "Vacio")!
    @State var img3: UIImage = UIImage(named: "Vacio")!
    @State var imgV: UIImage = UIImage(named: "Vacio")!
    @State var url1 = ""
    @State var url2 = ""
    @State var url3 = ""
    @State var urlV = ""
    var imgEmpty: UIImage = UIImage(named: "Vacio")! // Para comparar si una foto se ha alterado

    // Atributos
    @State var searchAttributes = false
    @State var searchAttributesField = ""
    @State var selectedAttributes: [String] = []

    // Alertas
    @State var alertNoFaceDetected = false
    @State var alertMissingFields = false
    @State var alertApiError = false

    @State var signIn = false

    var body: some View {
        ZStack{
        ScrollView(showsIndicators: false) {
            VStack {
                header
                Group {
                    nameField
                    Divider()
                    aboutMeField
                    Divider()
                    ageField
                    Divider()
                }
                Group {
                    genderField
                    Divider()
                    lookingForView
                    Divider()
                    imagesView
                    Divider()
                    faceImageView
                }
                Divider()
                attributesView
                Divider()
                saveButton
            }
            .padding()
        }
        .frame(width: UIScreen.screenWidth * (UIDevice.isIPhone ? 0.9 : 0.6), height: UIScreen.screenHeight * (UIDevice.isIPhone ? 0.85 : 0.7 ))
        .background(.ultraThinMaterial)
        .mask(RoundedRectangle(cornerRadius: CARD_RADIUS, style: .continuous))
        .onTapGesture {
            hideKeyboard()
        }
        .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
        .padding(UIDevice.isIPhone ? 0 : 200)
        // Cuando todo se ha completado correctamente iniciamos sesion
        .onChange(of: signIn) { _ in
            if signIn {
                vm.fetchCurrentUser()
                vm.signedIn = true
            }
        }
        .onAppear{
            withAnimation {
                vm.showUserManualButton = false
            }
        }
            
            if vm.showLoadingView {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
            }
            
            Spacer()
                .alert(isPresented: $alertApiError) {
                    Alert(
                        title: Text("Problema con servidor"),
                        message: Text("Vuelve a intentarlo más tarde.")
                    )
                }
        }
    }

    var header: some View {
        VStack {
            LogoSignIn()
            TitleText(texto: "Personaliza tu perfil")
                .padding(.bottom, 20)
        }.alert(isPresented: $alertMissingFields) {
            Alert(
                title: Text("Faltan Datos"),
                message: Text("Asegurese que todos los campos están rellenos")
            )
        }
    }

    // Picker para elegir el genero propio
    var lookingForView: some View {
        VStack {
            SectionTitle("Busco")
            HStack(spacing: 20) {
                ForEach(0 ..< lookingForOptions.count) { index in
                    HStack {
                        Button(action: {
                            lookingForOptions[index].isSelected.toggle()
                        }) {
                            HStack {
                                if lookingForOptions[index].isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .animation(.easeIn)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.primary)
                                }
                                Text(lookingForOptions[index].gender).foregroundColor(.primary)
                                    .font(.callout)
                            }
                        }.buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.vertical, 2)
                }
            }
        }.padding(.vertical)
    }

    var imagesView: some View {
        VStack {
            SectionTitle("Fotos")
            HStack {
                UploadImageButton(image: $img1)
                Spacer()
                UploadImageButton(image: $img2)
                Spacer()
                UploadImageButton(image: $img3)
            }
        }.padding(.vertical)
    }

    var faceImageView: some View {
        HStack {
            VStack {
                SectionTitle("Foto de cara")
                HStack {
                    Text("Esta foto no se mostrará en tu perfil.")
                        .font(.callout)
                    Spacer()
                }.alert(isPresented: $alertNoFaceDetected) {
                    Alert(
                        title: Text("Foto No Válida"),
                        message: Text("La foto de cara no es válida. Vuelva a probar con otra.")
                    )
                }
            }
            Spacer()
            UploadImageButton(image: $imgV)
                

        }.padding(.vertical)
        
    }

    var nameField: some View {
        VStack {
            SectionTitle("Nombre")
            TextFieldCustom(placeholder: "Nombre", text: $name)
        }.padding(.vertical)
    }

    var aboutMeField: some View {
        VStack {
            SectionTitle("Sobre Mi")
            TextEditorCustom(text: $aboutMe)
        }.padding(.vertical)
    }

    var ageField: some View {
        VStack {
            SectionTitle("Edad")
            DatePicker("Fecha de Nacimiento", selection: $birthDate, in: calendarStart ... calendarEnd, displayedComponents: [.date])
        }.padding(.vertical)
    }

    var genderField: some View {
        VStack {
            SectionTitle("Mi Genero")
            Picker("Genero", selection: $selectedGender) {
                ForEach(genders, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
        }.padding(.vertical)
    }

    var attributesView: some View {
        VStack {
            if !searchAttributes {
                SectionTitle("Atributos Disponibles")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        HStack {
                            Button {
                                withAnimation {
                                    searchAttributes.toggle()
                                }
                            } label: {
                                AttributeView(text: "Buscar", icon: "magnifyingglass.circle.fill")
                            }
                        }
                        ForEach(vm.attributes.indices, id: \.self) { index in
                            if !vm.attributes[index].isSelected {
                                Button {
                                    withAnimation {
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
            } else {
                //Vista de busqueda de atributo
                Button {
                    withAnimation() {
                        searchAttributes.toggle()
                    }
                } label: {
                    HStack{
                        Label("Volver", systemImage: "chevron.backward")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                //Campo de busqueda
                TextFieldCustom(placeholder: "Ej: Cantante", text: $searchAttributesField)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(vm.attributes.indices, id: \.self) { index in
                            if !vm.attributes[index].isSelected && vm.attributes[index].text.lowercased().contains(searchAttributesField.lowercased()) {
                                Button {
                                    withAnimation {
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
            SectionTitle("Atributos Seleccionados")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(vm.attributes.indices, id: \.self) { index in
                        if vm.attributes[index].isSelected {
                            Button {
                                withAnimation {
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

    var saveButton: some View {
        Button {
            // Pasamos los datos de los atributos y los generos a sus arrays correspondientes
            selectedAttributes.removeAll()
            vm.attributes.forEach { a in
                if a.isSelected {
                    selectedAttributes.append(a.text)
                }
            }

            lookingFor.removeAll()
            lookingForOptions.forEach { g in
                if g.isSelected {
                    lookingFor.append(g.gender)
                }
            }

            if (name == "" || aboutMe == "" || selectedAttributes.isEmpty || lookingFor.isEmpty || img1 == imgEmpty || img2 == imgEmpty || img3 == imgEmpty || imgV == imgEmpty) {
                alertMissingFields = true
            } else {
                vm.showLoadingView = true
                save()
            }

        } label: {
            ButtonCustom(text: "Guardar", color: Color.accentColor)
                .padding(.top, 20)
        }
        
    }

    private func save() {
        // Usamos dispatch para asegurarnos que las fotos se han subido antes de guardar el resto de los daots
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "any-label-name")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        // Sacar el id del usuario
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }

        // Path de las fotos
        let refFoto1 = FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/foto1")
        guard let foto1Data = img1.jpegData(compressionQuality: 0.8) else { return }
        let refFoto2 = FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/foto2")
        guard let foto2Data = img2.jpegData(compressionQuality: 0.8) else { return }
        let refFoto3 = FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/foto3")
        guard let foto3Data = img3.jpegData(compressionQuality: 0.8) else { return }
        let refFotoV = FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/fotoV")
        guard let fotoVData = imgV.jpegData(compressionQuality: 0.8) else { return }

        dispatchQueue.async {
            dispatchGroup.enter()
            refFoto1.putData(foto1Data, metadata: nil) { _, err in
                if let err = err {
                    if SHOW_DEBUG_CONSOLE {
                        print("Error subiendo foto1: \(err)")
                    }
                    return
                }

                refFoto1.downloadURL { url1, err in
                    if let err = err {
                        if SHOW_DEBUG_CONSOLE {
                            print("Error descargando url foto1: \(err)")
                        }
                        return
                    }

                    self.url1 = url1?.absoluteString ?? ""

                    if SHOW_DEBUG_CONSOLE {
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
                    if SHOW_DEBUG_CONSOLE {
                        print("Error subiendo foto2: \(err)")
                    }
                    return
                }

                refFoto2.downloadURL { url2, err in
                    if let err = err {
                        if SHOW_DEBUG_CONSOLE {
                            print("Error descargando url foto1: \(err)")
                        }
                        return
                    }

                    self.url2 = url2?.absoluteString ?? ""

                    if SHOW_DEBUG_CONSOLE {
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
                    if SHOW_DEBUG_CONSOLE {
                        print("Error subiendo foto3: \(err)")
                    }
                    return
                }

                refFoto3.downloadURL { url3, err in
                    if let err = err {
                        if SHOW_DEBUG_CONSOLE {
                            print("Error descargando url foto3: \(err)")
                        }
                        return
                    }

                    self.url3 = url3?.absoluteString ?? ""
                    if SHOW_DEBUG_CONSOLE {
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
                    if SHOW_DEBUG_CONSOLE {
                        print("Error subiendo fotoV: \(err)")
                    }
                    return
                }

                refFotoV.downloadURL { urlV, err in
                    if let err = err {
                        if SHOW_DEBUG_CONSOLE {
                            print("Error descargando url fotoV: \(err)")
                        }
                        return
                    }

                    self.urlV = urlV?.absoluteString ?? ""
                    validateImg(url: self.urlV)

                    if SHOW_DEBUG_CONSOLE {
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

                userData = ["uid": uid, "nombre": name, "sobreMi": aboutMe, "genero": selectedGender, "busco": lookingFor, "url1": url1, "url2": url2, "url3": url3, "urlV": urlV, "fechaNacimiento": birthDate, "atributos": selectedAttributes, "ubicacion": GeoPoint(latitude: lm.lastLocation?.coordinate.latitude ?? 0.0, longitude: lm.lastLocation?.coordinate.longitude ?? 0.0)]

                FirebaseManager.shared.firestore.collection("usuarios")
                    .document(uid).setData(userData) { err in
                        if let err = err {
                            if SHOW_DEBUG_CONSOLE {
                                print("Error guardar: \(err)")
                            }
                            vm.showLoadingView = false
                            return
                        }
                        vm.showLoadingView = false
                    }
            }
        }
    }

    func validateImg(url: String) {
        let json = ["url": url]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)

            let url = NSURL(string: "\(vm.apiURL)/validarFoto/")!
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"

            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, error in
                if error != nil {
                    DispatchQueue.main.async {
                        alertApiError = true
                        vm.showLoadingView = false
                    }
                    if SHOW_DEBUG_CONSOLE {
                        print("Error ->", error ?? "")
                    }
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(Bool.self, from: data!)
                    self.alertNoFaceDetected = !result
                    self.signIn = result
                    if SHOW_DEBUG_CONSOLE {
                        print("Result -> \(result)")
                    }

                } catch {
                    if SHOW_DEBUG_CONSOLE {
                        print("Error -> \(error)")
                    }
                }
            }

            task.resume()
        } catch {
            if SHOW_DEBUG_CONSOLE {
                print(error)
            }
        }
    }
}
