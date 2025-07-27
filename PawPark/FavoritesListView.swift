//
//  FavoritesListView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-23.
//


import SwiftUI

struct FavoritesListView: View {
    let parks: [DogPark]

    var body: some View {
        List(parks) { park in
            NavigationLink(destination: ParkDetailView(park: park)) {
                Text(park.name)
                    .foregroundColor(.primary)
            }
            .listRowBackground(Color.bgPrimary)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.bgPrimary)
        .navigationTitle("Favorites")
    }
}

