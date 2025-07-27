//
//  FirebaseManager.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-21.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class FirebaseManager {
    static let shared = FirebaseManager()
    let auth: Auth
    let db: Firestore
    let storage: Storage
    
    private init() {
        auth = Auth.auth()
        db = Firestore.firestore()
        storage = Storage.storage()
    }
}
