//
//  FirebaseManager.swift
//  Cherry
//
//  Created by Deyan on 29/1/22.
//

import Firebase
import Foundation

class FirebaseManager: NSObject {
    let auth: Auth
    let storage: Storage
    let firestore: Firestore

    static let shared = FirebaseManager()

    override init() {
        FirebaseApp.configure()

        auth = Auth.auth()
        storage = Storage.storage()
        firestore = Firestore.firestore()

        super.init()
    }
}
