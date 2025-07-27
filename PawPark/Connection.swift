//
//  Connection.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-25.
//


import Foundation

struct Connection: Identifiable, Codable {
    let id: String            // Firestore document ID
    let userID: String        // current user
    let friendID: String      // connected user
    let createdAt: Date
}