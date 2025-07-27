//
//  Rating.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-21.
//


import Foundation

struct Rating: Identifiable {
    let id: String       // Firestore document ID
    let parkID: String   // ID of the park being reviewed
    let userID: String   // UID of the user who submitted the review
    let stars: Int       // 1…5
    let comment: String  // the review text
    let timestamp: Date  // when the review was created
}
