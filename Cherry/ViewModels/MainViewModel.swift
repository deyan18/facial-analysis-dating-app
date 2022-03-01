//
//  ViewModel.swift
//  Cherry
//
//  Created by Deyan on 29/1/22.
//

import CoreLocation
import CoreLocationUI
import Firebase
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var DEBUG = false
    @Published var tabbarIndex = 0
    
    // Usuario
    @Published var usuarioPrincipal: UsuarioModel? //Guardamos el usuario que ha iniciado sesión
    @Published var usuarios: [UsuarioModel] = [] //Lista con todos los usuario de la bbdd
    @Published var usuariosRango: [UsuarioModel] = [] //Lista con los usuarios dentro del rango de distancia, edad, sexo y ordenados por preferncia de similitud
    @Published var usuariosCompatibles: [UsuarioModel] = []
    //Toggles
    @Published var abrirFiltro = false
    @Published var usuarioLoggedIn = false //Para indicar que el login es correcto y pasar a vista Para Ti / Para cerrar sesion y volver a login
    @Published var apiEnUso = false //Para controlar que no se hagan varias llamadas a la api simultanemente
    @Published var loadingView = false
    @Published var errorApi = false
    //Limites
    @Published var distanciaPermitida = 50000.0 //Rango de distancia (en metros) de usuarios que se van a mostrar

    init() {
        self.fetchAtributos()
    }

    //Bajar los datos del usuario que ha iniciado sesion de la BD
    func fetchUsuarioActual() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }

        FirebaseManager.shared.firestore.collection("usuarios")
            .document(uid).getDocument { snapshot, err in
                if let err = err {
                    print("Error fetch usuario actual:", err)
                    return
                }

                guard let data = snapshot?.data() else { return }


                self.usuarioPrincipal = .init(data: data)
                
                //Una vez cargado el usuario llamamos
                self.cargarDatosUsuario()
                
                if(DEBUGCONSOLE){
                    print(data)
                    print(self.usuarioPrincipal!)
                }
            }
    }
    
    private func cargarDatosUsuario(){
        self.fetchUsuarios()
        self.fetchUsuariosCompatibles()
        self.fetchRecientes()
    }


    func cerrarSesion() {
        usuarioLoggedIn = false
        try? FirebaseManager.shared.auth.signOut()
    }

    //Bajar todos los usuarios de la BD
    func fetchUsuarios() {
        usuarios.removeAll() //Eliminamos los del fetch anterior
        FirebaseManager.shared.firestore.collection("usuarios").addSnapshotListener { querySnapshot, err in
            if let err = err {
                print("Error obteniendo usuarios: \(err)")
                return
            }

            querySnapshot?.documents.forEach({ snap in
                let u = UsuarioModel(data: snap.data())
                //Si el usuario NO es el que ha iniciado sesión lo introducimos en usuarios[]
                if u.uid != FirebaseManager.shared.auth.currentUser?.uid {
                    self.usuarios.append(u)
                }

            })
            if (DEBUGCONSOLE){
                print(self.usuarios)
            }
            
            //Una vez tengamos todos los usuarios pasamos a ver cuales cumplen los criterios
            //self.calcularRasgos()

        }
    }
    private var compatiblesListener: ListenerRegistration?

    func fetchUsuariosCompatibles() {
        guard let uidPrincipal = usuarioPrincipal?.uid else { return }
        compatiblesListener?.remove()
        
        FirebaseManager.shared.firestore
            .collection("compatibles")
            .document(uidPrincipal)
            .collection("usuarios")
            .addSnapshotListener { querySnapshot, err in
                if let err = err {
                    print("Error obteniendo comparaciones \(err)")
                    return
                }
                
                print("FUERA")

                self.usuariosCompatibles.removeAll() //Eliminamos los del fetch anterior
                querySnapshot?.documents.forEach({ queryDoc in
                    let data = queryDoc.data()
            
                    print("DENTRO \(self.usuarios.count)")
                

                        for (index, u) in self.usuarios.enumerated(){
                            print("COMPROBANDO ")
                            if data["uid"] as! String == u.uid {
                                self.usuarios[index].distanciaRasgos = data["distanciaRasgos"] as? Double ?? -1.0
                                self.usuariosCompatibles.append(self.usuarios[index])
                            }
                        }
                    
                })
            }
    }
    
    private func calcularRasgos(){
        self.calcularRangoDistancia()
        self.enviarParaComparar()
    }

    /*
    //Comprueba rangos de edad, distancia, genero y ordena por similitud o diferencia
    func calcularRecomendaciones() {
        usuariosRango.removeAll() //Vaciamos de la llamada anterior
        
        //Ponemos valores por defecto si nos encontramos algun nil
        let min = usuarioPrincipal?.edadMin ?? 18
        let max = usuarioPrincipal?.edadMax ?? 99
        let genero = usuarioPrincipal?.genero ?? ""
        let generosBuscaPrincipal = usuarioPrincipal?.busco ?? []

        for (index, usuario) in usuarios.enumerated() {
            // Calculamos la distancia del usuario al usuario principal
            usuarios[index].distanciaMetros = usuario.ubicacion.distance(from: usuarioPrincipal?.ubicacion ?? CLLocation(latitude: 0.0, longitude: 0.0))

            if(DEBUGCONSOLE){
                print("Distancia usuario: \(usuarios[index].distanciaMetros), perimitida: \(distanciaPermitida)")
            }
            
            // Comprobamos si los generos que buscan corresponden
            if generosBuscaPrincipal.contains(usuario.genero) && usuario.busco.contains(genero) {
                // Comprobamos si la distancia permitida se cumple
                if usuarios[index].distanciaMetros <= distanciaPermitida && usuarios[index].edad >= min && usuarios[index].edad <= max {
                    usuariosRango.append(usuarios[index])
                }
            }
        }

        DispatchQueue.main.async {
            //Odenamos la lista ya sea por similitud o diferencia
            if self.usuarioPrincipal?.buscaSimilar ?? true {
                self.usuariosRango = self.usuariosRango.sorted(by: { $0.distanciaRasgos < $1.distanciaRasgos })
            } else {
                self.usuariosRango = self.usuariosRango.sorted(by: { $0.distanciaRasgos > $1.distanciaRasgos })
            }
        }
    }
     */
/*
    //Llama a la api con DeepFace para obtener las diferencias en los rasgos
    func similitudFotos() {
        usuariosSimilitud = SimilitudModel() //Vaciamos de la llamada anterior

        //Rellenamos con los datos
        usuariosSimilitud.urlPrincipal = usuarioPrincipal!.urlV
        usuarios.forEach { usuario in
            usuariosSimilitud.urls.append(usuario.urlV)
            usuariosSimilitud.uids.append(usuario.uid)
            usuariosSimilitud.distanciasRasgos.append(-1.0) //Distancia por defecto
        }

        if apiEnUso { //Si ya hay una llamada a la api cancelamos
            return
        } else {
            apiEnUso = true
            
            if(DEBUGCONSOLE){
                print("LLAMADA A API INICIADA")
            }

            let json = ["urlPrincipal": usuariosSimilitud.urlPrincipal, "urls": usuariosSimilitud.urls, "uids": usuariosSimilitud.uids, "distanciasRasgos": usuariosSimilitud.distanciasRasgos] as [String: Any]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)

                let url = NSURL(string: "\(URLAPI)/similitudFotos/")!
                let request = NSMutableURLRequest(url: url as URL)
                request.httpMethod = "POST"

                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData

                let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, error in
                    if error != nil {
                        print("Error -> \(error)")
                        DispatchQueue.main.async {
                            self.apiEnUso = false
                            self.errorApi = true
                        }
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(SimilitudModel.self, from: data!)
                        print("Result -> \(result)")
                        
                        //Una vez tengamos el resultado pasamos a rellenar los datos
                        self.actualizarSimilitud(result)
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
*/
    /*
    //Insertamos las distancias de rasgos obtenidas en los usuarios correspondientes
    func actualizarSimilitud(_ usuariosSimilitud: SimilitudModel) {
        DispatchQueue.main.async {
            self.apiEnUso = false
            for (indexUsuario, usuario) in self.usuarios.enumerated() {
                for (indexSimilitud, uid) in usuariosSimilitud.uids.enumerated() {
                    if usuario.uid == uid {
                        /* El plan era que si se encontraba con un -1 volviese a llamar la api pero si hay una foto que no vale eso hace que entre en un bucle para siempre
                        if usuariosSimilitud.distanciasRasgos[indexSimilitud] == -1.0 {
                            self.similitudFotos()
                            return
                        }*/
                        self.usuarios[indexUsuario].distanciaRasgos = usuariosSimilitud.distanciasRasgos[indexSimilitud]
                    }
                }
            }
            
            //Una vez puestas todas las distancias volvemos a llamar para ordenar por ellas
            self.calcularRecomendaciones()
        }
    }
    */
    func calcularRangoDistancia(){
        usuariosRango.removeAll() //Vaciamos de la llamada anterior
        
        let genero = usuarioPrincipal?.genero ?? ""
        let generosBuscaPrincipal = usuarioPrincipal?.busco ?? []

        for (index, usuario) in usuarios.enumerated() {
            // Calculamos la distancia del usuario al usuario principal
            usuarios[index].distanciaMetros = usuario.ubicacion.distance(from: usuarioPrincipal?.ubicacion ?? CLLocation(latitude: 0.0, longitude: 0.0))

            if(DEBUGCONSOLE){
                print("Distancia usuario: \(usuarios[index].distanciaMetros), perimitida: \(distanciaPermitida)")
            }
            
            // Comprobamos si los generos que buscan corresponden
            if generosBuscaPrincipal.contains(usuario.genero) && usuario.busco.contains(genero) {
                // Comprobamos si la distancia permitida se cumple
                if usuarios[index].distanciaMetros <= distanciaPermitida {
                    usuariosRango.append(usuarios[index])
                }
            }
        }
    }
    
    func enviarParaComparar(){
        
        guard let uidPrincipal = usuarioPrincipal?.uid else {return}
        guard let urlPrincipal = usuarioPrincipal?.urlV else {return}
        var urls: [String] = []
        var uids: [String] = []
        var distanciasRasgos: [Double] = []
        usuariosRango.forEach { usuario in
            urls.append(usuario.urlV)
            uids.append(usuario.uid)
            distanciasRasgos.append(-1.0) //Distancia por defecto
        }

        if apiEnUso { //Si ya hay una llamada a la api cancelamos
            return
        } else {
            apiEnUso = true
            
            if(DEBUGCONSOLE){
                print("LLAMADA A API INICIADA")
            }

            let json = ["uidPrincipal": uidPrincipal,"urlPrincipal": urlPrincipal, "urls": urls, "uids": uids, "distanciasRasgos": distanciasRasgos] as [String: Any]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)

                let url = NSURL(string: "\(URLAPI)/similitudFotos/")!
                let request = NSMutableURLRequest(url: url as URL)
                request.httpMethod = "POST"

                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData

                let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, error in
                    if error != nil {
                        print("Error -> \(error)")
                        DispatchQueue.main.async {
                            self.apiEnUso = false
                            self.errorApi = true
                        }
                        return
                    }
                    DispatchQueue.main.async {
                    self.apiEnUso = false
                    }
                }

                task.resume()

            } catch {
                DispatchQueue.main.async {
                    self.apiEnUso = false
                    self.errorApi = true
                }
                print(error)
            }
        }    }

    @Published var recientes: [RecienteModel] = []
    private var recientesListener: ListenerRegistration?
    //Bajar los mensajes recientes de la bbdd
    func fetchRecientes() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        recientesListener?.remove()
        recientes.removeAll()

        recientesListener = FirebaseManager.shared.firestore
            .collection("recientes")
            .document(uid)
            .collection("mensajes")
            .order(by: "fecha", descending: true)
            .addSnapshotListener { querySnapshot, err in
                if let err = err {
                    print("Error obteniendo mensajes recientes: \(err)")
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ cambio in
                    let nuevo = RecienteModel(data: cambio.document.data())
                    var encontrado = false
                    for (indexReciente, reciente) in self.recientes.enumerated(){
                        if(reciente.urlFoto == nuevo.urlFoto){
                            encontrado = true
                            self.recientes[indexReciente] = nuevo
                        }
                    }
                    if(!encontrado){
                        self.recientes.append(nuevo)
                    }
                })
                
             
                self.recientes = self.recientes.sorted(by: { $0.fecha > $1.fecha })
                
            }
    }

    // Universal
    @Published var usuarioSeleccionado: UsuarioModel? = nil
    @Published var esconderBarra = false

    @Published var atributos: [AtributoModel] = []

    func fetchAtributos() {
        atributos.removeAll()
        FirebaseManager.shared.firestore.collection("atributos").document("atributos").getDocument { snapshot, err in
            if let err = err {
                print("Error obteniendo atributos: \(err)")
                return
            }

            print("Atributos obtenidos correctamente")

            guard let data = snapshot?.data() else { return }

            print(data)

            let arrayStrings = data["arrayAtributos"] as! [String]

            arrayStrings.forEach { a in
                self.atributos.append(AtributoModel(texto: a))
            }
        }
    }

    func eliminarUsuarioActual() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let refFotos = [FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/foto1"), FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/foto2"), FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/foto3"), FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/fotoV")]

        refFotos.forEach { ref in
            ref.delete { err in
                if let err = err {
                    print("Error eliminando foto: \(err)")
                }
            }
        }

        FirebaseManager.shared.auth.currentUser?.delete(completion: { err in
            if let err = err {
                print("Error eliminando cuenta: \(err)")
            }

            FirebaseManager.shared.firestore.collection("usuarios")
                .document(uid).delete { err in
                    if let err = err {
                        print("Error eliminando cuenta: \(err)")
                    }
                    self.usuarioLoggedIn.toggle()
                }
        })
    }

    func actualizarUbicacion(ubicacion: CLLocation) {
        guard let uid = usuarioPrincipal?.uid else { return }
        let data = ["ubicacion": GeoPoint(latitude: ubicacion.coordinate.latitude, longitude: ubicacion.coordinate.longitude ?? 0.0)]
        FirebaseManager.shared.firestore.collection("usuarios").document(uid).updateData(data)
    }

    func actualizarLimitesEdad() {
        guard let uid = usuarioPrincipal?.uid else { return }
        let data = ["edadMin": usuarioPrincipal?.edadMin, "edadMax": usuarioPrincipal?.edadMax]
        FirebaseManager.shared.firestore.collection("usuarios").document(uid).updateData(data)
    }

    func actualizarRasgosBusca() {
        guard let uid = usuarioPrincipal?.uid else { return }
        let data = ["buscaSimilar": usuarioPrincipal?.buscaSimilar]
        FirebaseManager.shared.firestore.collection("usuarios").document(uid).updateData(data)
    }
}

