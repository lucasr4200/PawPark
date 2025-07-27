//
//  NonceHelper.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-21.
//
import Foundation
import CryptoKit

/// Adapted from Firebase docs
func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] = Array(
      "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
    )
    var result = ""
    var remaining = length

    while remaining > 0 {
        let randoms = (0..<16).map { _ in UInt8.random(in: 0...255) }
        randoms.forEach { r in
            if remaining == 0 { return }
            if r < charset.count {
                result.append(charset[Int(r)])
                remaining -= 1
            }
        }
    }
    return result
}

func sha256(_ input: String) -> String {
    let data = Data(input.utf8)
    let hash = SHA256.hash(data: data)
    return hash.compactMap { String(format: "%02x", $0) }.joined()
}
