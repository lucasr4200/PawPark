//
//  QRScannerView.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-25.
//


import SwiftUI
import AVFoundation

/// A UIViewControllerRepresentable that shows a live camera feed
/// and calls `onScan` as soon as it reads a QR code string.
struct QRScannerView: UIViewControllerRepresentable {
    /// Called with the raw code string when a QR is detected.
    var onScan: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        // no-op
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let onScan: (String) -> Void
        init(onScan: @escaping (String) -> Void) { self.onScan = onScan }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            // Pull first QR metadata
            if let m = metadataObjects.compactMap({ $0 as? AVMetadataMachineReadableCodeObject })
                                     .first(where: { $0.type == .qr }),
               let code = m.stringValue
            {
                // Stop the session before callback
                (output.connection(with: .video)?.inputPorts.first?.formatDescription as? AVCaptureSession)?.stopRunning()
                DispatchQueue.main.async {[weak self] in
                    self?.onScan(code)
                }
            }
        }
    }
}

/// A plain UIViewController that sets up an AVCaptureSession for QR.
class ScannerViewController: UIViewController {
    weak var delegate: AVCaptureMetadataOutputObjectsDelegate?
    private let session = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let device = AVCaptureDevice.default(for: .video),
              let input  = try? AVCaptureDeviceInput(device: device)
        else {
            return
        }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(delegate, queue: .main)
        output.metadataObjectTypes = [.qr]

        // Preview
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.layer.bounds
        view.layer.addSublayer(preview)

        session.startRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // ensure preview layer fills
        view.layer.sublayers?.first?.frame = view.bounds
    }
}
