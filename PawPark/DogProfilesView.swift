//
//  DogProfilesView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-25.
//

import SwiftUI

struct DogProfilesView: View {
    @EnvironmentObject var dogsRepo: DogsRepository
    @Environment(\.dismiss) var dismiss

    @State private var dogNames: [String] = []
    @State private var isSaving = false

    var body: some View {
        ZStack {
            // 1️⃣ full-screen custom background
            Color.bgPrimary
                .ignoresSafeArea()

            // 2️⃣ override Form’s white with our bg
            Form {
                // Dog name inputs
                Section(header: Text("Your Dog(s)")) {
                    ForEach(dogNames.indices, id: \.self) { idx in
                        HStack {
                            TextField("Dog name", text: $dogNames[idx])
                                .padding(12)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)

                            if dogNames.count > 1 {
                                Button {
                                    dogNames.remove(at: idx)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Button {
                        dogNames.append("")
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Another Dog")
                        }
                        .foregroundColor(Color.buttonBg)
                    }
                }
                .listRowBackground(Color.bgPrimary)

                // Save section
                Section {
                    if isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.bgPrimary)
                    } else {
                        Button("Save") {
                            Task {
                                isSaving = true
                                let profiles = dogNames
                                    .map { $0.trimmingCharacters(in: .whitespaces) }
                                    .filter { !$0.isEmpty }
                                    .map { DogProfile(id: UUID().uuidString, name: $0) }
                                await DogsRepository.shared.setDogs(profiles)
                                isSaving = false
                                dismiss()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.buttonBg)
                        .foregroundColor(Color.buttonTxt)
                        .cornerRadius(8)
                        .disabled(dogNames.allSatisfy { $0.trimmingCharacters(in: .whitespaces).isEmpty })
                        .listRowBackground(Color.bgPrimary)
                    }
                }
            }
            .scrollContentBackground(.hidden)    // hide default white behind form
            .background(Color.bgPrimary)         // paint form background
            .listStyle(.plain)
        }
        .navigationTitle("My Dogs")
        .onAppear {
            dogNames = DogsRepository.shared.dogs.map(\.name)
            if dogNames.isEmpty { dogNames = [""] }
        }
    }
}
