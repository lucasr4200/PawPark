//
//  PawParkApp.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-20.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}


@main
struct PawParkApp: App {
    init() {
        // register app delegate for Firebase setup
        @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.bgPrimary)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.secondaryLabel]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance  = appearance
        

    }
    
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.bgPrimary          // <- your semantic background
                    .ignoresSafeArea()
                
                ContentView()
                    .environmentObject(AuthViewModel.shared)
                    .environmentObject(SettingsViewModel.shared)
                    .environmentObject(DogsRepository.shared)
                    .environmentObject(FavoritesRepository.shared)
                    .accentColor(.buttonBg)
            }
        }
    }
}
