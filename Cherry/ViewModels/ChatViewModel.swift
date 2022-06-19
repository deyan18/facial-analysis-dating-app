//
//  ChatViewModel.swift
//  Cherry
//
//  Created by Deyan on 17/2/22.
//

import Firebase
import SwiftUI

class ChatViewModel: ObservableObject {

    @Published var messages: [MessageModel] = []
    @Published var currentUser: UserModel?
    @Published var selectedUser: UserModel?
    private var messagesListener: ListenerRegistration?

    func sendMessage(text: String, date: Date) {
        guard let senderUID = currentUser?.uid else { return }
        guard let receiverUID = selectedUser?.uid else { return }

        let docSender = FirebaseManager.shared.firestore.collection("mensajes").document(senderUID).collection(receiverUID).document()

        let docReceiver = FirebaseManager.shared.firestore.collection("mensajes").document(receiverUID).collection(senderUID).document()

        let mensajeData1 = ["emisorId": senderUID, "receptorId": receiverUID, "texto": text, "fecha": date] as [String: Any]
        let mensajeData2 = ["emisorId": senderUID, "receptorId": receiverUID, "texto": text, "fecha": date] as [String: Any]

        docSender.setData(mensajeData1) { err in
            if let err = err {
                print("Error: \(err)")
                return
            }
        }
        docReceiver.setData(mensajeData2) { err in
            if let err = err {
                print("Error: \(err)")
                return
            }
        }
        saveRecentMessage(text: text, date: date)
    }

    func fetchMessages() {
        guard let emisorId = currentUser?.uid else { return }
        guard let receptorId = selectedUser?.uid else { return }

        messagesListener?.remove()

        messagesListener = FirebaseManager.shared.firestore
            .collection("mensajes")
            .document(emisorId)
            .collection(receptorId)
            .order(by: "fecha")
            .addSnapshotListener { querySnapshot, err in
                if let err = err {
                    print("Error obteniendo mensajes \(err)")
                    return
                }
                self.messages.removeAll()
                querySnapshot?.documents.forEach({ queryDoc in
                    let data = queryDoc.data()
                    self.messages.append(MessageModel(data: data))
                })
            }
    }

    func saveRecentMessage(text: String, date: Date) {
        guard let senderUID = currentUser?.uid else { return }
        guard let receiverUID = selectedUser?.uid else { return }

        let docSender = FirebaseManager.shared.firestore
            .collection("recientes")
            .document(senderUID)
            .collection("mensajes")
            .document(receiverUID)

        let docReceiver = FirebaseManager.shared.firestore
            .collection("recientes")
            .document(receiverUID)
            .collection("mensajes")
            .document(senderUID)

        let dataSender = [
            "texto": text,
            "fecha": date,
            "emisorId": senderUID,
            "receptorId": receiverUID,
            "urlFoto": selectedUser?.url1 ?? "",
            "nombre": selectedUser?.name ?? "",
            "esLeido": true,
        ] as [String: Any]

        let dataReceiver = [
            "texto": text,
            "fecha": date,
            "emisorId": senderUID,
            "receptorId": receiverUID,
            "urlFoto": currentUser?.url1 ?? "",
            "nombre": currentUser?.name ?? "",
            "esLeido": false,
        ] as [String: Any]

        docSender.setData(dataSender) { err in
            if let err = err {
                print("Error guardando en mensajes recientes: \(err)")
                return
            }
        }

        docReceiver.setData(dataReceiver) { err in
            if let err = err {
                print("Error guardando en mensajes recientes: \(err)")
                return
            }
        }
    }

    func markAsRead() {
        guard let senderUID = currentUser?.uid else { return }
        guard let receiverUID = selectedUser?.uid else { return }

        let doc = FirebaseManager.shared.firestore
            .collection("recientes")
            .document(senderUID)
            .collection("mensajes")
            .document(receiverUID)
        let messageData = ["esLeido": true] as [String: Any]

        doc.updateData(messageData)
    }
}

