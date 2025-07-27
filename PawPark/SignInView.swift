//
//  SignInView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-21.
//
// SignInView.swift
// PawPark

import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct SignInView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var currentNonce: String?

    var body: some View {
        NavigationStack{
            ZStack{
                Color.bgPrimary.ignoresSafeArea()
                VStack(spacing: 24) {
                    Spacer()
                    
                    // 1️⃣ Email/Password Sign In/Up
                    NavigationLink("Sign in / Sign up with Email") {
                        EmailAuthView()
                            .environmentObject(authVM)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    // 2️⃣ Apple Sign-In Button
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            let nonce = randomNonceString()
                            currentNonce = nonce
                            
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = sha256(nonce)
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                guard
                                    let appleCred = authResults.credential as? ASAuthorizationAppleIDCredential,
                                    let tokenData = appleCred.identityToken,
                                    let idToken = String(data: tokenData, encoding: .utf8),
                                    let nonce = currentNonce
                                else {
                                    print("🚨 Unable to extract Apple credentials")
                                    return
                                }
                                
                                let credential = OAuthProvider.appleCredential(
                                    withIDToken: idToken,
                                    rawNonce: nonce,
                                    fullName: appleCred.fullName
                                )
                                
                                Auth.auth().signIn(with: credential) { authResult, error in
                                    if let error = error {
                                        print("❌ Firebase signIn error:", error)
                                    } else {
                                        print("✅ Signed in to Firebase as:", authResult?.user.uid ?? "<none>")
                                    }
                                }
                                
                            case .failure(let error):
                                print("❌ Apple sign-in failed:", error)
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 45)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(8)
                    
                    // 3️⃣ Continue as Guest
                    Button("Continue as Guest") {
                        Task {
                            do {
                                _ = try await authVM.signInAnonymously()
                            } catch {
                                print("❌ Anonymous sign-in failed:", error)
                            }
                        }
                    }
                    .padding(.top)
                    
                    Spacer()
                }
                .padding(.top, 50)
                .navigationTitle("Welcome")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
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
