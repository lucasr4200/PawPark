//
//  FullScreenImageViewer.swift
//  PawPark
//
//  Created by Lucas Rasmusson on 2025-07-22.
//


import SwiftUI

/// A view that displays a swipeable, pinch-to-zoom image gallery in full screen.
struct FullScreenImageViewer: View {
    let imageURLs: [String]
    @Binding var currentIndex: Int
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(imageURLs.enumerated()), id: \.offset) { idx, urlString in
                    ZoomableScrollView {
                        AsyncImage(url: URL(string: urlString)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            case .failure:
                                Color.gray
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    .tag(idx)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

/// A UIViewRepresentable wrapper that provides pinch-to-zoom for any SwiftUI content.
struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        // Embed the SwiftUI content
        let hosting = UIHostingController(rootView: content)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear
        scrollView.addSubview(hosting.view)

        // Pin hosting view to scrollView
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            hosting.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            hosting.view.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // Nothing to update
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            // zoom the first subview (the SwiftUI content)
            return scrollView.subviews.first
        }
    }
}