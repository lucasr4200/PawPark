//
//  ConnectionQRView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-25.
//


import SwiftUI
import CoreImage.CIFilterBuiltins

struct ConnectionQRView: View {
    let userID: String

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        VStack {
            Text("Your QR Code")
                .font(.headline)

            if let img = generateQR(from: userID) {
                Image(uiImage: img)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    // ↑ bump these numbers up
                    .frame(width: 300, height: 300)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .contextMenu {
                        Button("Copy UID") {
                            UIPasteboard.general.string = userID
                        }
                    }
            }
        }
        .padding()
        .background(Color.bgPrimary)
    }

    private func generateQR(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        guard let output = filter.outputImage,
              let cgimg = context.createCGImage(output, from: output.extent)
        else { return nil }
        return UIImage(cgImage: cgimg)
    }
}
