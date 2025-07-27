//
//  SettingsView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-20.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var dogsRepo: DogsRepository
    @StateObject var settingsVM = SettingsViewModel.shared
    @State private var showSignOutAlert = false

    var body: some View {
        List {
            // Sign-Out Section
            Section {
                Button("Sign Out", role: .destructive) {
                    showSignOutAlert = true
                }
                .foregroundColor(.red)
            }
            .listRowBackground(Color.bgPrimary)
            // Customization Sub-Menu
            Section("Customization") {
                NavigationLink("Background Photo") {
                    CustomizationView()
                        .environmentObject(settingsVM)
                }
            }
            .listRowBackground(Color.bgPrimary)

            // Account Settings Sub-Menu
            Section("Account Settings") {
                NavigationLink("Change Username") {
                    AccountSettingsView()
                }
                NavigationLink("My Dogs") {
                    DogProfilesView()
                        .environmentObject(DogsRepository.shared)
                }
            }
            .listRowBackground(Color.bgPrimary)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.bgPrimary)
        .navigationTitle("Settings")
        .alert("Are you sure you want to sign out?", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                do {
                    try authVM.signOut()
                } catch {
                    print("Sign-out error:", error)
                }
            }
        }
    }
}
