//
//  ChatViewModel.swift
//  Cherry
//
//  Created by Deyan on 17/2/22.
//

import Firebase
import SwiftUI

class ChatViewModel: ObservableObject {
    // Chat

    @Published var mensajes: [MensajeModel] = []
    @Published var usuarioPrincipal: UsuarioModel?
    @Published var usuarioSeleccionado: UsuarioModel?

    func enviarMensaje(texto: String, fecha: Date) {
        guard let emisorId = usuarioPrincipal?.uid else { return }
        guard let receptorId = usuarioSeleccionado?.uid else { return }

        let documento1 = FirebaseManager.shared.firestore.collection("mensajes").document(emisorId).collection(receptorId).document()

        let documento2 = FirebaseManager.shared.firestore.collection("mensajes").document(receptorId).collection(emisorId).document()

        let mensajeData1 = ["emisorId": emisorId, "receptorId": receptorId, "texto": texto, "fecha": fecha] as [String: Any]
        let mensajeData2 = ["emisorId": emisorId, "receptorId": receptorId, "texto": texto, "fecha": fecha] as [String: Any]

        documento1.setData(mensajeData1) { err in
            if let err = err {
                print("Error enviando mensaje \(err)")
                return
            }
        }

        documento2.setData(mensajeData2) { err in
            if let err = err {
                print("Error enviando mensaje \(err)")
                return
            }
        }

        guardarMensajeReciente(texto: texto, fecha: fecha)
    }

    private var mensajesListener: ListenerRegistration?

    func updateMensajes() {
        guard let emisorId = usuarioPrincipal?.uid else { return }
        guard let receptorId = usuarioSeleccionado?.uid else { return }

        mensajesListener?.remove()

        mensajesListener = FirebaseManager.shared.firestore
            .collection("mensajes")
            .document(emisorId)
            .collection(receptorId)
            .order(by: "fecha")
            .addSnapshotListener { querySnapshot, err in
                if let err = err {
                    print("Error obteniendo mensajes \(err)")
                    return
                }

                querySnapshot?.documentChanges.forEach({ cambio in
                    if cambio.type == .added {
                        let data = cambio.document.data()
                        self.mensajes.append(MensajeModel(data: data))
                    }

                })
                /* querySnapshot?.documents.forEach({ queryDoc in
                     let data = queryDoc.data()
                     self.mensajes.append(MensajeModel(data: data))
                 }) */
            }
    }

    private var fetchMensajesListener: ListenerRegistration?

    func fetchMensajes() {
        guard let emisorId = usuarioPrincipal?.uid else { return }
        guard let receptorId = usuarioSeleccionado?.uid else { return }

        fetchMensajesListener?.remove()

        FirebaseManager.shared.firestore
            .collection("mensajes")
            .document(emisorId)
            .collection(receptorId)
            .order(by: "fecha")
            .addSnapshotListener { querySnapshot, err in
                if let err = err {
                    print("Error obteniendo mensajes \(err)")
                    return
                }
                self.mensajes.removeAll()
                querySnapshot?.documents.forEach({ queryDoc in
                    let data = queryDoc.data()
                    self.mensajes.append(MensajeModel(data: data))
                })
            }
    }

    func guardarMensajeReciente(texto: String, fecha: Date) {
        guard let emisorId = usuarioPrincipal?.uid else { return }
        guard let receptorId = usuarioSeleccionado?.uid else { return }

        let documentoEmisor = FirebaseManager.shared.firestore
            .collection("recientes")
            .document(emisorId)
            .collection("mensajes")
            .document(receptorId)

        let documentoReceptor = FirebaseManager.shared.firestore
            .collection("recientes")
            .document(receptorId)
            .collection("mensajes")
            .document(emisorId)

        let datosEmisor = [
            "texto": texto,
            "fecha": fecha,
            "emisorId": emisorId,
            "receptorId": receptorId,
            "urlFoto": usuarioSeleccionado?.url1 ?? "",
            "nombre": usuarioSeleccionado?.nombre ?? "",
            "esLeido": true,
        ] as [String: Any]

        let datosReceptor = [
            "texto": texto,
            "fecha": fecha,
            "emisorId": emisorId,
            "receptorId": receptorId,
            "urlFoto": usuarioPrincipal?.url1 ?? "",
            "nombre": usuarioPrincipal?.nombre ?? "",
            "esLeido": false,
        ] as [String: Any]

        documentoEmisor.setData(datosEmisor) { err in
            if let err = err {
                print("Error guardando en mensajes recientes: \(err)")
                return
            }
        }

        documentoReceptor.setData(datosReceptor) { err in
            if let err = err {
                print("Error guardando en mensajes recientes: \(err)")
                return
            }
        }
    }

    func marcarComoLeido() {
        guard let emisorId = usuarioPrincipal?.uid else { return }
        guard let receptorId = usuarioSeleccionado?.uid else { return }

        let documento = FirebaseManager.shared.firestore
            .collection("recientes")
            .document(emisorId)
            .collection("mensajes")
            .document(receptorId)
        let mensajeData = ["esLeido": true] as [String: Any]

        documento.updateData(mensajeData)
    }
}

