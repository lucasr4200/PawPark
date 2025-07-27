//
//  DogsRepository.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-25.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class DogsRepository: ObservableObject {
    static let shared = DogsRepository()
    @Published private(set) var dogs: [DogProfile] = []

    private let db = FirebaseManager.shared.db
    private var handle: AuthStateDidChangeListenerHandle?

    private init() {
        // Whenever auth state changes, reload the dogs list
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { await self?.loadDogs() }
        }
    }

    /// Fetches the current user's dogs from their Firestore user document
    func loadDogs() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.dogs = []
            return
        }
        let ref = db.collection("users").document(uid)
        do {
            let snap = try await ref.getDocument()
            if let data = snap.data(), let arr = data["dogs"] as? [[String:Any]] {
                self.dogs = arr.compactMap { dict in
                    guard let id = dict["id"] as? String,
                          let name = dict["name"] as? String
                    else { return nil }
                    return DogProfile(id: id, name: name)
                }
            } else {
                self.dogs = []
            }
        } catch {
            print("Error loading dogs:", error)
            self.dogs = []
        }
    }

    /// Replaces the user’s dogs array in Firestore with a new list
    func setDogs(_ newDogs: [DogProfile]) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = db.collection("users").document(uid)
        let dicts = newDogs.map { ["id": $0.id, "name": $0.name] }
        do {
            try await ref.updateData(["dogs": dicts])
            self.dogs = newDogs
        } catch {
            print("Error setting dogs:", error)
        }
    }
}