//
//  ConnectionsListView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-25.
//


import SwiftUI
import FirebaseAuth

struct ConnectionsListView: View {
    @StateObject private var repo = ConnectionsRepository.shared
    @State private var showingScanner = false
    @State private var scannedUserID: String?
    @State private var showConnectAlert = false
    
    private enum Mode: String, CaseIterable, Identifiable {
        case myQR       = "My QR"
        case connections = "Connections"
        var id: String { rawValue }
    }
    
    @State private var mode: Mode = .myQR
    
    var body: some View {
        ZStack {
            // 1️⃣ Full-screen background
            Color.bgPrimary
                .ignoresSafeArea()
            
            
            VStack(spacing: 16) {
                // 2️⃣ Mode picker
                Picker("", selection: $mode) {
                    ForEach(Mode.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
                .padding(.top, 16)
                
                // 3️⃣ Content
                switch mode {
                case .myQR:
                    Spacer()

                    if let uid = Auth.auth().currentUser?.uid {
                        VStack(spacing: 16) {
                            
                            ConnectionQRView(userID: uid)
                                  .aspectRatio(1, contentMode: .fit)
                                  .padding(20)
                                  .background(Color.bgPrimary)
                                  .cornerRadius(12)
                                  .padding(.horizontal, 16)
                            
                            Button {
                                showingScanner = true
                            } label: {
                                Image(systemName: "camera.viewfinder")
                                    .font(.title2)
                                    .padding()
                                    .background(Color.buttonBg)
                                    .foregroundColor(Color.buttonTxt)
                                    .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity) //centre
                    }
                    
                case .connections:
                  ScrollView {
                    VStack(spacing: 12) {
                      ForEach(repo.connections) { conn in
                          NavigationLink {
                            // placeholder for future detail view
                            Text("Profile for \(conn.friendID)")
                          } label: {
                            ConnectionRow(friendID: conn.friendID)
                          }
                      }
                    }
                    .padding(.top, 8)
                  }
                }
                Spacer(minLength: 16)
            }
        }
        .navigationTitle("Connections")
        .task { await repo.loadConnections() }
        .alert("Connect with this user?", isPresented: $showConnectAlert, presenting: scannedUserID) { userID in
            Button("Yes") {
                Task {
                    // Write two‐way connection:
                    await ConnectionsRepository.shared.addMutualConnection(between: userID)
                    await repo.loadConnections()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: { userID in
            Text("User ID: \(userID)")
        }
        .fullScreenCover(isPresented: $showingScanner) {
            QRScannerView { code in
                // 1️⃣ capture the scanned ID
                scannedUserID = code
                // 2️⃣ dismiss scanner
                showingScanner = false
                // 3️⃣ show the confirmation alert
                showConnectAlert = true
            }
        }
    }
}


struct ConnectionRow: View {
  let friendID: String
  @State private var name    = ""
  @State private var dogs    = [String]()
  @State private var isLoading = true

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        if isLoading {
          ProgressView()
        } else {
          Text(name.isEmpty ? friendID : name)
            .font(.headline)
          if !dogs.isEmpty {
            Text(joinNames(dogs))
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
        }
      }
      Spacer()
    }
    .padding()
    .background(Color.white.opacity(0.2))
    .cornerRadius(8)
    .padding(.horizontal)
    .task {
      await fetchProfile()
    }
  }

  func fetchProfile() async {
    do {
      // 1) user display name
      let userDoc = try await FirebaseManager.shared.db
        .collection("users").document(friendID)
        .getDocument()
      let ud = userDoc.data() ?? [:]
      name = ud["displayName"] as? String ?? ""

      // 2) their dogs subcollection
      let dogsSnap = try await FirebaseManager.shared.db
        .collection("users").document(friendID)
        .collection("dogs")
        .getDocuments()
      dogs = dogsSnap.documents
        .compactMap { $0.data()["name"] as? String }

    } catch {
      print("Error fetching profile for \(friendID):", error)
    }
    isLoading = false
  }

  /// Helper to join “A, B, and C”
  func joinNames(_ arr: [String]) -> String {
    switch arr.count {
    case 0: return ""
    case 1: return arr[0]
    case 2: return arr.joined(separator: " and ")
    default:
      let allButLast = arr.dropLast().joined(separator: ", ")
      return "\(allButLast), and \(arr.last!)"
    }
  }
}
