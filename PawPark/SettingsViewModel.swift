//
//  SettingsViewModel.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-22.
//

import SwiftUI
import FirebaseAuth
import UIKit
import PhotosUI

/// Manages user-specific customization like background photo
final class SettingsViewModel: ObservableObject {
    static let shared = SettingsViewModel()
    @Published var backgroundImage: UIImage?

    private var authHandle: AuthStateDidChangeListenerHandle?

    private init() {
        // Listen for auth changes to reload background when user signs in/out
        authHandle = FirebaseManager.shared.auth.addStateDidChangeListener { [weak self] _, _ in
            self?.loadBackgroundImage()
        }
    }

    /// Load background image for current user from UserDefaults
    func loadBackgroundImage() {
        guard let uid = AuthViewModel.shared.user?.uid else { return }
        let key = "bgImage-\(uid)"
        if let data = UserDefaults.standard.data(forKey: key),
           let img  = UIImage(data: data) {
            backgroundImage = img
        }
    }

    /// Save selected background image for current user
    func saveBackgroundImage(_ image: UIImage) {
        guard let uid = AuthViewModel.shared.user?.uid else { return }
        let key = "bgImage-\(uid)"
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: key)
            backgroundImage = image
        }
    }
}
