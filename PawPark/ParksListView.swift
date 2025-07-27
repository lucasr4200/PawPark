//
//  ParksListView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-20.
//
import SwiftUI

struct ParksListView: View {
    let parks: [DogPark]
    let defaultCity: String?
    
    @State private var searchCity: String = ""
    
    // Filter & sort parks
    private var displayedParks: [DogPark] {
        // Determine which city to use for filtering
        if !searchCity.isEmpty {
            // user typed a city
            return parks
                .filter { $0.city.caseInsensitiveCompare(searchCity) == .orderedSame }
                .sorted { $0.name < $1.name }
        } else if let dc = defaultCity, !dc.isEmpty {
            // filter by the device’s city
            return parks
                .filter { $0.city.caseInsensitiveCompare(dc) == .orderedSame }
                .sorted { $0.name < $1.name }
        } else {
            // no filter: show all parks alphabetically
            return parks.sorted { $0.name < $1.name }
        }
    }
    
    var body: some View {
        List(displayedParks) { park in
            //use a destination-based NavigationLink so we don’t need DogPark to be Hashable
            NavigationLink(destination: ParkDetailView(park: park)) {
                Text(park.name)
            }
            .listRowBackground(Color.bgPrimary) //colour for rows
        }
        
        .scrollContentBackground(.hidden)
        .background(Color.bgPrimary) //colour for page
        
        .searchable(
            text: $searchCity,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search in a different city?"
        )
        .navigationTitle(
            searchCity.isEmpty
                ? "Parks in \(defaultCity ?? "Your City")"
                : "Parks in \(searchCity)"
        )
    }
}
