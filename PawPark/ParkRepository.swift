//
//  ParkRepository.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-21.
//
import Foundation
import FirebaseFirestore
import CoreLocation

@MainActor
final class ParkRepository: ObservableObject {
    @Published var parks: [DogPark] = []

    func loadParks() async {
        do {
            let snapshot = try await FirebaseManager.shared.db
                .collection("parks")
                .getDocuments()
            let docs = snapshot.documents

            self.parks = docs.compactMap { doc in
                let data = doc.data()

                // required fields
                guard
                    let name  = data["name"]            as? String,
                    let city  = data["city"]            as? String,
                    let lat   = data["latitude"]        as? Double,
                    let lon   = data["longitude"]       as? Double,
                    let water = data["hasFreeWater"]    as? Bool,
                    let area  = data["offLeashAreaSqM"] as? Double
                else {
                    return nil
                }

                // optional photoURLs
                let urls = data["photoURLs"] as? [String] ?? []

                return DogPark(
                    id: doc.documentID,
                    name: name,
                    city: city,
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    hasFreeWater: water,
                    offLeashAreaSqM: area,
                    photoURLs: urls
                )
            }
        } catch {
            print("Error loading parks:", error)
        }
    }
}
