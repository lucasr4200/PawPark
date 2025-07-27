//
//  CustomizationView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-22.
//

import SwiftUI
import PhotosUI
import UIKit
import FirebaseAuth

struct CustomizationView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @State private var photoItem: PhotosPickerItem?
    @State private var loadError: String?

    var body: some View {
        ZStack{
            Color.bgPrimary.ignoresSafeArea()
            ScrollView{
                VStack(spacing: 20) {
                    if let img = settingsVM.backgroundImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                    } else {
                        Text("No custom background set.")
                            .foregroundColor(.secondary)
                    }
                    
                    PhotosPicker(
                        selection: $photoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Text("Choose Background Photo")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.buttonBg)
                            .foregroundColor(Color.buttonTxt)
                            .cornerRadius(8)
                    }
                    .onChange(of: photoItem) { newItem in
                        Task {
                            do {
                                guard let data = try await newItem?.loadTransferable(type: Data.self),
                                      let uiImg = UIImage(data: data) else {
                                    loadError = "Could not load image data."
                                    return
                                }
                                settingsVM.saveBackgroundImage(uiImg)
                            } catch {
                                loadError = "Failed to import image."
                                print("Image load error:", error)
                            }
                        }
                    }
                    
                    if let error = loadError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Spacer()
                }
                .padding() //vstack bg
                .background(Color.bgPrimary)
            }
            .background(Color.bgPrimary) //scrollview bg
    }
        .navigationTitle("Customization")
    }
}
