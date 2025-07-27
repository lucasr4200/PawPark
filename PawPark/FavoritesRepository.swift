//
//  FavoritesRepository.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-23.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class FavoritesRepository: ObservableObject {
    static let shared = FavoritesRepository()
    @Published private(set) var favoriteParkIDs: Set<String> = []

    private let db = FirebaseManager.shared.db
    private var handle: AuthStateDidChangeListenerHandle?

    private init() {
        // Listen for auth changes to load favorites
        handle = FirebaseAuth.Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task {
                await self?.loadFavorites()
            }
        }
    }

    func loadFavorites() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            favoriteParkIDs = []
            return
        }
        let ref = db.collection("users").document(uid)
        do {
            let snap = try await ref.getDocument()
            if let data = snap.data(), let ids = data["favoriteParkIDs"] as? [String] {
                favoriteParkIDs = Set(ids)
            } else {
                favoriteParkIDs = []
            }
        } catch {
            print("Error loading favorites:", error)
        }
    }

    func isFavorite(_ parkID: String) -> Bool {
        favoriteParkIDs.contains(parkID)
    }

    func toggleFavorite(_ parkID: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = db.collection("users").document(uid)
        do {
            if isFavorite(parkID) {
                // remove
                try await ref.updateData(["favoriteParkIDs": FieldValue.arrayRemove([parkID])])
                favoriteParkIDs.remove(parkID)
            } else {
                // add
                try await ref.updateData(["favoriteParkIDs": FieldValue.arrayUnion([parkID])])
                favoriteParkIDs.insert(parkID)
            }
        } catch {
            print("Error toggling favorite:", error)
        }
    }
}
