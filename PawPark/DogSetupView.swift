//
//  DogSetupView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-25.
//

import SwiftUI

struct DogSetupView: View {
    /// Called when the user finishes entering their dog names
    let onComplete: () -> Void
    @EnvironmentObject var dogsRepo: DogsRepository
    @State private var dogNames: [String] = [""]
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Your Dog(s)")) {
                    ForEach(Array(dogNames.indices), id: \ .self) { idx in
                        TextField("Dog name", text: $dogNames[idx])
                    }
                    Button("Add Another Dog") {
                        dogNames.append("")
                    }
                }
                Section {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task {
                                isSaving = true
                                // Build profiles
                                let profiles = dogNames
                                    .map { $0.trimmingCharacters(in: .whitespaces) }
                                    .filter { !$0.isEmpty }
                                    .map { DogProfile(id: UUID().uuidString, name: $0) }
                                await dogsRepo.setDogs(profiles)
                                isSaving = false
                                onComplete()
                            }
                        }
                        .disabled(dogNames.allSatisfy { $0.trimmingCharacters(in: .whitespaces).isEmpty })
                    }
                }
            }
            .navigationTitle("Add Your Dogs")
        }
    }
}
