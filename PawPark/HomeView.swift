//
//  ContentView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-20.
//


import SwiftUI
import MapKit
import FirebaseFirestore
import UIKit

/// Possible destinations from the HomeView's bottom sheet icons
enum Destination: Hashable {
    case list, map, favorites, connections, settings
}

struct HomeView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var dogsRepo: DogsRepository

    // MARK: - State Objects
    @StateObject private var locationManager = LocationManager()
    @StateObject private var repo = ParkRepository()

    // MARK: - Local State
    @State private var isExpanded = false
    @State private var path: [Destination] = []
    @State private var showInitialDogSetup = false

    // MARK: - Layout Constants
    let collapsedHeight: CGFloat = 350
    let expandedTopInset: CGFloat = 100

    // MARK: - Computed Properties
    /// The user’s current city from LocationManager
    private var defaultCity: String? { locationManager.city }

    /// Parks sorted by distance to the user (if location available)
    private var sortedParks: [DogPark] {
        guard let userLoc = locationManager.location else { return repo.parks }
        return repo.parks.sorted { p1, p2 in
            let l1 = CLLocation(latitude: p1.coordinate.latitude, longitude: p1.coordinate.longitude)
            let l2 = CLLocation(latitude: p2.coordinate.latitude, longitude: p2.coordinate.longitude)
            return l1.distance(from: userLoc) < l2.distance(from: userLoc)
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    // Background: user-customizable or default
                    Group {
                        if let uiImg = settingsVM.backgroundImage {
                            Image(uiImage: uiImg)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                        } else {
                            Image("dog_background")
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                        }
                    }
                    .overlay(Color.black.opacity(isExpanded ? 0.5 : 0))
                    .ignoresSafeArea()

                    bottomSheet(in: geo.size)
                }
            }
            .navigationDestination(for: Destination.self) { dest in
                switch dest {
                case .list:
                    ParksListView(parks: sortedParks, defaultCity: defaultCity)
                case .map:
                    ParksMapView(parks: sortedParks)
                case .favorites:
                        FavoritesListView( parks: repo.parks.filter { FavoritesRepository.shared.isFavorite($0.id) } )
                case .connections: ConnectionsListView()
                case .settings:
                    SettingsView()
                }
            }
        }
        .onAppear {
            Task {
                // 1️⃣ load parks + dogs
                await repo.loadParks()
                await dogsRepo.loadDogs()

                // 2️⃣ If we have a user AND no dogs yet → maybe show once
                if let user = authVM.user,
                   dogsRepo.dogs.isEmpty
                {
                    let key = "didShowDogSetup_\(user.uid)"
                    if !UserDefaults.standard.bool(forKey: key) {
                        showInitialDogSetup = true
                        UserDefaults.standard.set(true, forKey: key)
                    }
                }
            }
        }
        .sheet(isPresented: $showInitialDogSetup) {
            DogSetupView {
                showInitialDogSetup = false
            }
            .environmentObject(dogsRepo)
            .presentationDetents([.medium, .large])      // start medium, allow expansion
            .presentationDragIndicator(.visible)          // show the little grabber
        }
    }

    // MARK: - Bottom Sheet
    private func bottomSheet(in size: CGSize) -> some View {
        let collapsedY = size.height - collapsedHeight
        let expandedY = expandedTopInset

        // Favorite park = first sorted by distance
        let favorite = sortedParks.first ?? DogPark(
            id: UUID().uuidString,
            name: "Park",
            city: defaultCity ?? "",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            hasFreeWater: false,
            offLeashAreaSqM: 0,
            photoURLs: ["0"]
        )

        return VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.secondary)
                .frame(width: 40, height: 6)
                .padding(.top, 8)

            // Peek Content
            VStack(alignment: .leading, spacing: 12) {
                Text(greeting)
                    .font(.title2)
                    .bold()
                Text("You have \(Int.random(in: 0...10)) visits this week")
                    .foregroundColor(.secondary)
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 120)
                    .overlay(Text("Map snippet of \(favorite.name)"))
                    .cornerRadius(8)
                Button(action: { openDirections(to: favorite) }) {
                    Text("Start directions to \(favorite.name)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.buttonBg)
                        .foregroundColor(Color.buttonTxt)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // Icon Bar
            HStack {
                Spacer()
                Button { path.append(.list) } label: {
                    VStack { Image(systemName: "list.bullet"); Text("List") }
                }
                Spacer()
                Button { path.append(.map) } label: {
                    VStack { Image(systemName: "map"); Text("Map") }
                }
                Spacer()
                Button { path.append(.favorites) } label: {
                    VStack { Image(systemName: "heart"); Text("Favorites") }
                }
                Spacer()
                Button { path.append(.connections) } label: { IconLabel(name: "person.2.fill", text: "Conn") }
                Spacer()
                Button { path.append(.settings) } label: {
                    VStack { Image(systemName: "gearshape"); Text("Settings") }
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.bottom, 30)

            // Expanded Nearby List
            if isExpanded {
                VStack(alignment: .leading) {
                    Text("Nearby Parks")
                        .font(.headline)
                        .padding(.top)
                    ForEach(sortedParks.prefix(5), id: \.id) { park in
                        HStack {
                            Image(systemName: "pawprint.fill")
                            Text(park.name)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(width: size.width, height: size.height - expandedY, alignment: .top)
        .background(RoundedRectangle(cornerRadius: 16)
            .fill(Color(Color.bgPrimary)))
        .offset(y: isExpanded ? expandedY : collapsedY)
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.height < -50 {
                    isExpanded = true
                } else if value.translation.height > 50 {
                    isExpanded = false
                }
            }
        )
        .animation(.interactiveSpring(), value: isExpanded)
    }

    // MARK: - Helper Methods
    private func openDirections(to park: DogPark) {
        let placemark = MKPlacemark(coordinate: park.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = park.name
        mapItem.openInMaps(launchOptions: nil)
    }
    
    private func joinNames(_ names: [String]) -> String {
            switch names.count {
            case 0:
                return ""
            case 1:
                return names[0]
            case 2:
                return names.joined(separator: " and ")
            default:
                let allButLast = names.dropLast().joined(separator: ", ")
                return "\(allButLast), and \(names.last!)"
            }
        }

    // Greeting based on time and user name
    private var greeting: String {
            // 1) Pick the correct prefix
            let hour = Calendar.current.component(.hour, from: Date())
            let prefix: String = {
                switch hour {
                case 5..<12:   return "Good morning"
                case 12..<17:  return "Good afternoon"
                default:       return "Good evening"
                }
            }()

            // 2) If the user has dogs, list them
            let dogNames = dogsRepo.dogs.map(\.name)
            if !dogNames.isEmpty {
                return "\(prefix) \(joinNames(dogNames))"
            }

            // 3) Fallback to their first name or just the prefix
            if let full = authVM.user?.displayName,
               !full.isEmpty,
               !authVM.isGuest
            {
                let first = full.split(separator: " ").first.map(String.init) ?? full
                return "\(prefix), \(first)"
            }

            return prefix
        }
}

struct IconLabel: View {
    let name: String, text: String
    var body: some View {
        VStack { Image(systemName: name); Text(text) }
            .foregroundColor(Color.buttonBg)
    }
}

#Preview {
    HomeView()
}
