//
//  ParksMapView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-20.
//

import SwiftUI
import MapKit

struct ParksMapView: View {
    @State private var region: MKCoordinateRegion
    let parks: [DogPark]

    init(parks: [DogPark]) {
        self.parks = parks
        if let first = parks.first {
            _region = State(initialValue: MKCoordinateRegion(
                center: first.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        } else {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            ))
        }
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: parks) { park in
            MapAnnotation(coordinate: park.coordinate) {
                NavigationLink(destination: ParkDetailView(park: park)) {
                    Image(systemName: "pawprint.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue.opacity(0.75))
                        .clipShape(Circle())
                }
            }
        }
        .navigationTitle("Map")
        .edgesIgnoringSafeArea(.all)
    }
}

