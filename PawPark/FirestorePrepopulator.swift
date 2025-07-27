//
//  FirestorePrepopulator.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-21.
//
import FirebaseFirestore
import CoreLocation

//func prepopulateParks() async throws {
//  let db = Firestore.firestore()
//  let batch = db.batch()
//  for park in SampleData.parks {
//    let doc = db.collection("parks").document(park.id)
//    batch.setData([
//      "name": park.name,
//      "city": park.city,
//      "latitude": park.coordinate.latitude,
//      "longitude": park.coordinate.longitude,
//      "hasFreeWater": park.hasFreeWater,
//      "offLeashAreaSqM": park.offLeashAreaSqM
//    ], forDocument: doc)
//  }
//  try await batch.commit()
//  print("✅ Parks pre-populated")
//}
