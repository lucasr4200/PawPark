//
//  DogPark.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-20.
//

import Foundation
import CoreLocation

struct DogPark: Identifiable{
    let id: String
    let name: String
    let city: String
    let coordinate: CLLocationCoordinate2D
    let hasFreeWater: Bool
    let offLeashAreaSqM: Double
    let photoURLs: [String]
}

extension DogPark: Equatable {
    static func ==(lhs: DogPark, rhs: DogPark) -> Bool {
        return lhs.offLeashAreaSqM == rhs.offLeashAreaSqM
    }
}

extension DogPark: Comparable {
    static func < (lhs: DogPark, rhs: DogPark) -> Bool {
        // defines natural sort order (by area here)
        return lhs.offLeashAreaSqM < rhs.offLeashAreaSqM
    }
}

extension DogPark: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}



// for populating db
//
//struct SampleData {
//    static let parks: [DogPark] = [
//        // 1. Buena Vista Park – large riverside off-leash area
//        DogPark(
//            id: UUID().uuidString,
//            name: "Buena Vista Park",
//            city: "Edmonton",
//            coordinate: CLLocationCoordinate2D(
//                latitude: 53.51384515322054,
//                longitude: -113.54740089064504
//            ),
//            hasFreeWater: false,
//            offLeashAreaSqM: 660000  // ~66 ha off-leash meadow
//        ),
//
//        // 2. Coronation Park – river valley park with sports fields
//        DogPark(
//            id: UUID().uuidString,
//            name: "Coronation Park",
//            city: "Edmonton",
//            coordinate: CLLocationCoordinate2D(
//                latitude: 53.54164308003229,
//                longitude: -113.4927973634718
//            ),
//            hasFreeWater: true,
//            offLeashAreaSqM: 350000  // ~35 ha (baseball diamonds & lawns)
//        ),
//
//        // 3. William Hawrelak Park – iconic lake & river valley park
//        DogPark(
//            id: UUID().uuidString,
//            name: "William Hawrelak Park",
//            city: "Edmonton",
//            coordinate: CLLocationCoordinate2D(
//                latitude: 53.52806,
//                longitude: -113.54750
//            ),
//            hasFreeWater: true,
//            offLeashAreaSqM: 680000  // ~68 ha riverside open space
//        ),
//
//        // 4. Rundle Park – multi-use river valley trails & off-leash stretch
//        DogPark(
//            id: UUID().uuidString,
//            name: "Rundle Park",
//            city: "Edmonton",
//            coordinate: CLLocationCoordinate2D(
//                latitude: 53.56874,
//                longitude: -113.377985
//            ),
//            hasFreeWater: false,
//            offLeashAreaSqM: 125000  // ~12.5 ha linear ravine trail
//        ),
//
//        // 5. Mill Creek Ravine South – gravel off-leash corridor
//        DogPark(
//            id: UUID().uuidString,
//            name: "Mill Creek Ravine South",
//            city: "Edmonton",
//            coordinate: CLLocationCoordinate2D(
//                latitude: 53.53021,
//                longitude: -113.49121
//            ),
//            hasFreeWater: false,
//            offLeashAreaSqM: 80000   // ~8 ha of ravine trail
//        )
//    ]
//}
