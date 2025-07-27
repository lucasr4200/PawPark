//
//  ParkDetailView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-20.
//
import SwiftUI
import MapKit
import FirebaseAuth
import FirebaseFirestore

/// Displays details for a DogPark, including a tappable photo carousel and reviews.
struct ParkDetailView: View {
    let park: DogPark

    @EnvironmentObject var authVM: AuthViewModel
    @State private var ratings: [Rating] = []
    @State private var newStars: Int = 3
    @State private var newComment: String = ""
    @State private var isSubmitting: Bool = false
    @State private var loadError: String?

    // For full-screen photo viewer
    @State private var currentPhotoURL: String = ""
    @State private var currentPhotoIndex: Int = 0
    @State private var isShowingFullScreen = false

    var body: some View {
        ZStack{
            Color.bgPrimary.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Photo Carousel
                    if !park.photoURLs.isEmpty {
                        TabView {
                            ForEach(Array(park.photoURLs.enumerated()), id: \.offset) { idx, urlString in
                                Button(action: {
                                    currentPhotoIndex = idx
                                    isShowingFullScreen = true
                                }) {
                                    AsyncImage(url: URL(string: urlString)) { phase in
                                        switch phase {
                                        case .empty:
                                            ZStack {
                                                Color.gray.opacity(0.3)
                                                ProgressView()
                                            }
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        case .failure:
                                            Color.gray
                                        @unknown default:
                                            Color.gray
                                        }
                                    }
                                    .frame(height: 200)
                                    .clipped()
                                }
                                .tag(idx)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .frame(height: 200)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                Text("No photos")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                    }
                    
                    // Park Info
                    HStack {
                        Text("Free Water:").bold()
                        Spacer()
                        Image(systemName: park.hasFreeWater ? "checkmark.circle" : "xmark.circle")
                            .foregroundColor(park.hasFreeWater ? .green : .red)
                    }
                    HStack {
                        Text("Off-leash Area:").bold()
                        Spacer()
                        Text("\(Int(park.offLeashAreaSqM)) m²")
                    }
                    
                    Divider().padding(.vertical)
                    
                    // Ratings & Comments
                    Text("Ratings & Comments").font(.headline)
                    if ratings.isEmpty {
                        Text("No reviews yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(ratings) { r in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 2) {
                                    ForEach(0..<5) { i in
                                        Image(systemName: i < r.stars ? "star.fill" : "star")
                                    }
                                }
                                Text(r.comment)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text(r.timestamp, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // Submit Review
                    if let user = authVM.user, !authVM.isGuest {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Leave a review").font(.headline)
                            Picker("Stars", selection: $newStars) {
                                ForEach(1..<6) { s in Text("\(s)").tag(s) }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            TextEditor(text: $newComment)
                                .frame(height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary)
                                )
                            
                            Button(action: submitReview) {
                                if isSubmitting {
                                    ProgressView()
                                } else {
                                    Text("Submit Review")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.buttonBg)
                                        .foregroundColor(Color.buttonTxt)
                                        .cornerRadius(8)
                                }
                            }
                            .disabled(isSubmitting || newComment.trimmingCharacters(in: .whitespaces).isEmpty)
                            
                            if let error = loadError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    } else {
                        Text("Please sign in to leave a review.")
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                    
                    Spacer()
                }
                .padding()
            }
    }
        .navigationTitle(park.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task { await FavoritesRepository.shared.toggleFavorite(park.id) }
                } label: {
                    Image(systemName: FavoritesRepository.shared.isFavorite(park.id) ? "star.fill" : "star")
                }
            }
        }
        .task { await fetchReviews() }
        // Full-screen Photo Cover
        .fullScreenCover(isPresented: $isShowingFullScreen) {
            FullScreenImageViewer(
                    imageURLs: park.photoURLs,
                    currentIndex: $currentPhotoIndex,
                    isPresented: $isShowingFullScreen
                )
        }

    }

    // MARK: - Data Methods
    private func fetchReviews() async {
        do {
            ratings = try await RatingService.shared.fetchRatings(for: park.id)
        } catch {
            loadError = "Failed to load reviews."
            print("Error fetching ratings:", error)
        }
    }

    private func submitReview() {
        guard let user = authVM.user else { return }
        isSubmitting = true
        loadError = nil
        let review = Rating(
            id: UUID().uuidString,
            parkID: park.id,
            userID: user.uid,
            stars: newStars,
            comment: newComment.trimmingCharacters(in: .whitespacesAndNewlines),
            timestamp: Date()
        )
        Task {
            do {
                try await RatingService.shared.addRating(review)
                ratings.insert(review, at: 0)
                newStars = 3
                newComment = ""
            } catch {
                loadError = "Could not submit review."
                print("Error adding rating:", error)
            }
            isSubmitting = false
        }
    }
}
