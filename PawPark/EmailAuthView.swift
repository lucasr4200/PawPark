//
//  EmailAuthView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-22.
//


import SwiftUI
import FirebaseAuth

struct EmailAuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    enum Mode { case signIn, signUp }
    @State private var mode: Mode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showDogSetup = false
    
    var body: some View {
        ZStack{
            Color.bgPrimary.ignoresSafeArea()
                ScrollView {
                    Picker("", selection: $mode) {
                        Text("Sign In").tag(Mode.signIn)
                        Text("Sign Up").tag(Mode.signUp)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Text("Credentials")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    // MARK: Text Fields
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)

                        if mode == .signUp {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    Button(mode == .signIn ? "Sign In" : "Sign Up") {
                        handleAuth()
                    }
                    .disabled(!formIsValid)
                    .buttonStyle(PrimaryButtonStyle())
                    
                    
                    if showingError {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal)
                        }
                        Spacer(minLength: 50)
                    }
                
            }
        .scrollContentBackground(.hidden)
        .background(Color.bgPrimary)
        .listStyle(.plain)
        .navigationTitle(mode == .signIn ? "Sign In" : "Sign Up")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
                    .foregroundColor(Color.buttonBg)
            }
        }
        // dog sheet setup
        .sheet(isPresented: $showDogSetup) {
            DogSetupView {
                //once dogs finsihsed adding dismiss
                showDogSetup = false
                dismiss()
            }
            .environmentObject(DogsRepository.shared)
        }
    }
}

    private var formIsValid: Bool {
        guard !email.isEmpty, !password.isEmpty else { return false }
        if mode == .signUp { return password == confirmPassword }
        return true
    }

    private func handleAuth() {
        showingError = false
        Task {
            do {
                if mode == .signIn {
                    try await authVM.signIn(email: email, password: password)
                    dismiss()
                } else {
                    _ = try await authVM.signUp(email: email, password: password)
                    // AFTER sign up, prompt for dogs
                    showDogSetup = true
                }
            } catch {
                showingError = true
                errorMessage = error.localizedDescription
            }
        }
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 45)
            .frame(maxWidth: .infinity)
            .background(Color.buttonBg.opacity(configuration.isPressed ? 0.8 : 1))
            .foregroundColor(Color.buttonTxt)
            .cornerRadius(8)
            .padding(.horizontal)
    }
}
