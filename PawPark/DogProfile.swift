//
//  DogProfile.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-25.
//


import Foundation

struct DogProfile: Identifiable, Codable, Equatable {
    let id: String       // unique UUID
    let name: String     // dog’s name
}
