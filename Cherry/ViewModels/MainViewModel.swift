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
    // Users
    @Published var currentUser: UserModel?
    @Published var selectedUser: UserModel? = nil
    @Published var users: [UserModel] = [] // All users from DB
    @Published var usersWithinRange: [UserModel] = [] // Users within distnace, age and sex range
    @Published var usersAnalyzed: [UserModel] = [] // Users analyzed with DeepFace

    // Toggles
    @Published var openFilters = false
    @Published var signedIn = false
    @Published var apiInUse = false
    @Published var apiError = false
    @Published var showLoadingView = false
    @Published var showUserManualButton = true
    @Published var hideTabBar = false
    @Published var showDebug = false

    // Listeners
    private var usersListener: ListenerRegistration?
    private var usersAnalyzedListener: ListenerRegistration?
    private var recentMessagesListener: ListenerRegistration?

    // Other
    @Published var recentMessages: [RecentMessageModel] = []
    @Published var attributes: [AttributeModel] = []
    @Published var apiURL = "http://127.0.0.1:8000"
    @Published var tabbarIndex = 0

    init() {
        fetchAttributes()
    }

    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }

        FirebaseManager.shared.firestore.collection("usuarios")
            .document(uid).getDocument { snapshot, err in
                if let err = err {
                    print("Error: ", err)
                    return
                }

                guard let data = snapshot?.data() else { return }
                self.currentUser = .init(data: data)

                self.fetchUserDependantData()
            }
    }

    // Data that needs the user to be loaded first
    private func fetchUserDependantData() {
        fetchUsers()
        fetchUsersAnalyzed()
        fetchRecentMessages()
    }

    func signOut() {
        signedIn = false
        try? FirebaseManager.shared.auth.signOut()
    }

    private func fetchUsers() {
        usersListener?.remove()
        usersListener = FirebaseManager.shared.firestore.collection("usuarios").addSnapshotListener { querySnapshot, err in
            if let err = err {
                print("Error: ", err)
                return
            }

            self.users.removeAll() // To prevent duplicates

            querySnapshot?.documents.forEach({ snap in
                let u = UserModel(data: snap.data())
                if u.uid != self.currentUser?.uid {
                    self.users.append(u)
                }

            })
        }
    }

    private func fetchUsersAnalyzed() {
        guard let currentUserUID = currentUser?.uid else { return }
        usersAnalyzedListener?.remove()

        usersAnalyzedListener = FirebaseManager.shared.firestore
            .collection("compatibles")
            .document(currentUserUID)
            .collection("usuarios")
            .addSnapshotListener { querySnapshot, err in
                if let err = err {
                    print("Error: ", err)
                    return
                }

                self.usersAnalyzed.removeAll() // To prevent duplicates

                querySnapshot?.documents.forEach({ queryDoc in
                    let data = queryDoc.data()

                    for (index, user) in self.users.enumerated() {
                        if data["uid"] as! String == user.uid {
                            self.users[index].distanceFeatures = data["distanciaRasgos"] as? Double ?? -1.0
                            self.usersAnalyzed.append(self.users[index])
                            if SHOW_DEBUG_CONSOLE {
                                print("Added to usersAnalyzed: \(self.users[index].name)")
                            }
                        }
                    }

                })

                self.sortUsers()
            }
    }

    private func sortUsers() {
        DispatchQueue.main.async {
            if self.currentUser?.lookingForSimilar ?? true {
                self.usersAnalyzed = self.usersAnalyzed.sorted(by: { $0.distanceFeatures < $1.distanceFeatures })
            } else {
                self.usersAnalyzed = self.usersAnalyzed.sorted(by: { $0.distanceFeatures > $1.distanceFeatures })
            }
        }
    }

    // Takes users within established ranges and sends it to the API to be analyzed with DeepFace
    func analyzeUsers() {
        getUsersWithinRange()
        sendToAPI()
    }

    private func getUsersWithinRange() {
        usersWithinRange.removeAll()

        let gender = currentUser?.gender ?? ""
        let lookingFor = currentUser?.lookingFor ?? []
        let ageMin = currentUser?.ageMin ?? 18
        let ageMax = currentUser?.ageMax ?? 99
        let currentUserLocation = currentUser?.location ?? CLLocation(latitude: 0.0, longitude: 0.0)

        for (index, user) in users.enumerated() {
            users[index].distanceMetres = user.location.distance(from: currentUserLocation)

            if SHOW_DEBUG_CONSOLE {
                print("Distance: \(users[index].distanceMetres), allowed distance: \(DISTANCE_LIMIT)")
            }

            if lookingFor.contains(user.gender) && user.lookingFor.contains(gender) {
                if users[index].distanceMetres <= DISTANCE_LIMIT && users[index].age >= ageMin && users[index].age <= ageMax {
                    usersWithinRange.append(users[index])
                }
            }
        }
    }

    private func sendToAPI() {
        guard let currentUserUID = currentUser?.uid else {
            return
        }
        guard let currentUserURL = currentUser?.urlV else {
            return
        }

        // For JSON file
        var urls: [String] = []
        var uids: [String] = []
        var distanceFeatures: [Double] = []

        usersWithinRange.forEach { usuario in
            if SHOW_DEBUG_CONSOLE {
                print("Sending: \(usuario.name)")
            }
            urls.append(usuario.urlV)
            uids.append(usuario.uid)
            distanceFeatures.append(-1.0)
        }

        if apiInUse {
            return
        } else {
            apiInUse = true

            if SHOW_DEBUG_CONSOLE {
                print("API CALL")
            }

            let json = ["uidPrincipal": currentUserUID, "urlPrincipal": currentUserURL, "urls": urls, "uids": uids, "distanciasRasgos": distanceFeatures] as [String: Any]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)

                let url = NSURL(string: "\(apiURL)/similitudFotos/")!
                let request = NSMutableURLRequest(url: url as URL)
                request.httpMethod = "POST"

                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData

                let task = URLSession.shared.dataTask(with: request as URLRequest) { _, _, error in
                    if error != nil {
                        print("Error: ", error ?? "")
                        DispatchQueue.main.async {
                            self.apiInUse = false
                            self.apiError = true
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.apiInUse = false
                    }
                }

                task.resume()

            } catch {
                DispatchQueue.main.async {
                    self.apiInUse = false
                    self.apiError = true
                }
                print(error)
            }
        }
    }

    private func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        recentMessagesListener?.remove()
        recentMessages.removeAll()

        recentMessagesListener = FirebaseManager.shared.firestore
            .collection("recientes")
            .document(uid)
            .collection("mensajes")
            .order(by: "fecha", descending: true)
            .addSnapshotListener { querySnapshot, err in
                if let err = err {
                    print("Error: ", err)
                    return
                }

                querySnapshot?.documentChanges.forEach({ cambio in

                    let newRecentMessage = RecentMessageModel(data: cambio.document.data())
                    var alreadyIn = false
                    for (indexReciente, recentMessage) in self.recentMessages.enumerated() {
                        if recentMessage.url == newRecentMessage.url {
                            alreadyIn = true
                            self.recentMessages[indexReciente] = newRecentMessage
                        }
                    }
                    if !alreadyIn {
                        self.recentMessages.append(newRecentMessage)
                    }
                })

                self.recentMessages = self.recentMessages.sorted(by: { $0.date > $1.date })
            }
    }

    private func fetchAttributes() {
        attributes.removeAll()
        FirebaseManager.shared.firestore.collection("atributos").document("atributos").getDocument { snapshot, err in
            if let err = err {
                print("Error: \(err)")
                return
            }

            guard let data = snapshot?.data() else { return }

            let attributesStrings = data["arrayAtributos"] as! [String]

            attributesStrings.forEach { a in
                self.attributes.append(AttributeModel(text: a))
            }
        }
    }

    func deleteUserAccount() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }

        let refImages = [FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/foto1"), FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/foto2"), FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/foto3"), FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/fotoV"), FirebaseManager.shared.storage.reference(withPath: "fotos/\(uid)/fotoTemp")]

        refImages.forEach { ref in
            ref.delete { err in
                if let err = err {
                    print("Error: \(err)")
                }
            }
        }

        FirebaseManager.shared.auth.currentUser?.delete(completion: { err in
            if let err = err {
                print("Error: \(err)")
            }

            FirebaseManager.shared.firestore.collection("usuarios")
                .document(uid).delete { err in
                    if let err = err {
                        print("Error: \(err)")
                    }
                    self.signedIn.toggle()
                }
        })
    }

    func updateLocation(location: CLLocation) {
        guard let uid = currentUser?.uid else { return }
        let data = ["ubicacion": GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)]
        FirebaseManager.shared.firestore.collection("usuarios").document(uid).updateData(data)
        currentUser?.location = location
    }

    func updateAgeRange() {
        guard let uid = currentUser?.uid else { return }
        let data = ["edadMin": currentUser?.ageMin, "edadMax": currentUser?.ageMax]
        FirebaseManager.shared.firestore.collection("usuarios").document(uid).updateData(data as [String: Any])
    }

    func updateFeaturesPreference() {
        guard let uid = currentUser?.uid else { return }
        let data = ["buscaSimilar": currentUser?.lookingForSimilar]
        FirebaseManager.shared.firestore.collection("usuarios").document(uid).updateData(data as [String: Any])
    }
}
