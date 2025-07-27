//
//  ContentView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            if authVM.user != nil {
                // User is signed in (Apple or guest)
                HomeView()        // ← your draggable slider UI
            } else {
                // No user: show sign-in screen
                SignInView()
            }
        }
    }
}
