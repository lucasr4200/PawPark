//
//  RatingService.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-21.
//


import Foundation
import FirebaseFirestore

final class RatingService {
    static let shared = RatingService()
    private let db = FirebaseManager.shared.db

    /// Adds a new rating to Firestore under `ratings/`
    func addRating(_ rating: Rating) async throws {
        // Build a dictionary to write
        let data: [String: Any] = [
            "parkID":    rating.parkID,
            "userID":    rating.userID,
            "stars":     rating.stars,
            "comment":   rating.comment,
            "timestamp": Timestamp(date: rating.timestamp)
        ]
        // fire and forget new document
        _ = try await db.collection("ratings").addDocument(data: data)
    }

    /// Fetches all ratings for a given park, ordered newest first.
    func fetchRatings(for parkID: String) async throws -> [Rating] {
        let snapshot = try await db
            .collection("ratings")
            .whereField("parkID", isEqualTo: parkID)
            .order(by: "timestamp", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            let d = doc.data()
            guard
                let userID  = d["userID"]    as? String,
                let stars   = d["stars"]     as? Int,
                let comment = d["comment"]   as? String,
                let ts      = d["timestamp"] as? Timestamp
            else {
                return nil
            }
            return Rating(
                id: doc.documentID,
                parkID: parkID,
                userID: userID,
                stars: stars,
                comment: comment,
                timestamp: ts.dateValue()
            )
        }
    }
}
