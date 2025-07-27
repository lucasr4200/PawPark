//
//  AccountSettingsView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-22.
//

import SwiftUI
import FirebaseAuth

struct AccountSettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var displayName: String = ""
    @State private var isSaving: Bool = false

    var body: some View {
        ZStack{
            Color.bgPrimary.ignoresSafeArea()
            Form {
                Section(header: Text("Username")) {
                    TextField("Display Name", text: $displayName)
                        .onAppear {
                            displayName = authVM.user?.displayName ?? ""
                        }
                }
                Section {
                    if isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.bgPrimary)
                    } else {
                        Button("Save") {
                            Task {
                                isSaving = true
                                do {
                                    try await authVM.updateDisplayName(displayName.trimmingCharacters(in: .whitespaces))
                                } catch {
                                    print("Name update error:", error)
                                }
                                isSaving = false
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.buttonBg)
                        .foregroundColor(Color.buttonTxt)
                        .cornerRadius(8)
                        .listRowBackground(Color.bgPrimary)
                        .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.bgPrimary)
            .listStyle(.plain)
    }
        .navigationTitle("Account Settings")
    }
    
}
