//
//  AuthViewModel.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-21.
//
// AuthViewModel.swift

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

final class AuthViewModel: ObservableObject {
    static let shared = AuthViewModel()
    
    @Published var user: User?            // Firebase User
    @Published var isGuest: Bool = false  // anonymous
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    private init() {
        handle = FirebaseManager.shared.auth.addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isGuest = user?.isAnonymous ?? false
            
            // ────── FIRESTORE USER ONBOARDING ──────
            //create firestore users document the first time this uid signs in
            Task {
                guard let fbUser = user else { return }
                
                let ref = FirebaseManager.shared.db
                    .collection("users")
                    .document(fbUser.uid)
                
                do {
                    let snapshot = try await ref.getDocument()
                    if !snapshot.exists {
                        // New user – write their profile
                        try await ref.setData([
                             "isGuest": fbUser.isAnonymous,
                             "email": fbUser.email as Any,
                             "displayName": fbUser.displayName as Any,
                             "createdAt": FieldValue.serverTimestamp(),
                             "favoriteParkIDs": [],
                             "dogs": []
                         ])
                    }
                } catch {
                    print("Error writing user document:", error)
                }
            }
            // ────────────────────────────────────────
        }
    }
    
    func signInAnonymously() async throws {
        let _ = try await FirebaseManager.shared.auth.signInAnonymously()
    }
    
    func signUp(email: String, password: String) async throws {
        let result = try await FirebaseManager.shared.auth
            .createUser(withEmail: email, password: password)
        try await result.user.sendEmailVerification()
    }
    
    func signIn(email: String, password: String) async throws {
        let _ = try await FirebaseManager.shared.auth
            .signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try FirebaseManager.shared.auth.signOut()
    }
}


extension AuthViewModel {

  func updateDisplayName(_ newName: String) async throws {
    //update FirebaseAuth user
    guard let user = FirebaseAuth.Auth.auth().currentUser else {
      throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not signed in"])
    }
    let changeReq = user.createProfileChangeRequest()
    changeReq.displayName = newName
    try await changeReq.commitChanges()

    //write to `users/{uid}` doc
    let uid  = user.uid
    let data: [String: Any] = [
      "displayName": newName,
      "updatedAt": FieldValue.serverTimestamp()
    ]
    try await FirebaseManager.shared.db
      .collection("users")
      .document(uid)
      .setData(data, merge: true)
  }
}
