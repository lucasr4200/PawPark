//
//  ConnectionsRepository.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-25.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class ConnectionsRepository: ObservableObject {
    static let shared = ConnectionsRepository()
    private let db = FirebaseManager.shared.db

    @Published var connections: [Connection] = []

    private init() {}

    func loadConnections() async {
      guard let me = Auth.auth().currentUser?.uid else { return }
      do {
        let snap = try await db
          .collection("connections")
          .document(me)
          .collection("peers")
          .order(by: "createdAt")
          .getDocuments()

        self.connections = snap.documents.compactMap { doc in
          let data = doc.data()
          guard
            let friendID  = data["friendID"]    as? String,
            let ts        = data["createdAt"]   as? Timestamp
          else { return nil }

          return Connection(
            id: doc.documentID,               
            userID: me,
            friendID: friendID,
            createdAt: ts.dateValue()
          )
        }
      } catch {
        print("Error loading connections:", error)
      }
    }

    func addMutualConnection(between otherUID: String) async {
        guard let me = Auth.auth().currentUser?.uid else { return }
        let batch = db.batch()

        // me → them
        let doc1 = db
          .collection("connections")
          .document(me)
          .collection("peers")
          .document(otherUID)
        batch.setData(["friendID": otherUID, "createdAt": FieldValue.serverTimestamp()], forDocument: doc1)

        // them → me
        let doc2 = db
          .collection("connections")
          .document(otherUID)
          .collection("peers")
          .document(me)
        batch.setData(["friendID": me, "createdAt": FieldValue.serverTimestamp()], forDocument: doc2)

        try? await batch.commit()
    }
}
