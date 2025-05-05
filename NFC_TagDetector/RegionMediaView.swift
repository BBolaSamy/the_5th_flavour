//
//  RegionMediaView.swift
//  NFC_TagDetector
//
//  Created by George Saleip on 22.04.25.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import ZIPFoundation

struct RegionMediaView: View {
    @Binding var items: [MediaItem]
    @Binding var isPresented: Bool

    @State private var fullScreenItems: [MediaItem] = []
    @State private var selectedIndex: Int = 0
    @State private var isShowingGallery = false

    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(alignment: .center) {
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 12)

                    Spacer()

                    Button(action: exportAndShareMedia) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 12)
                }

                if items.isEmpty {
                    Text("No media available for this region.")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(items) { item in
                                PhotoThumbnailView(asset: item.asset) { _ in
                                    fullScreenItems = items
                                    selectedIndex = items.firstIndex(of: item) ?? 0
                                    isShowingGallery = true
                                }
                            }
                        }
                        .padding(8)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingGallery) {
            FullScreenGalleryView(mediaItems: fullScreenItems, currentIndex: selectedIndex)
        }
    }

    func exportAndShareMedia() {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let exportFolder = tempDir.appendingPathComponent("ExportedMedia", isDirectory: true)

        try? fileManager.removeItem(at: exportFolder)
        try? fileManager.createDirectory(at: exportFolder, withIntermediateDirectories: true)

        let dispatchGroup = DispatchGroup()

        for (index, item) in items.enumerated() {
            dispatchGroup.enter()
            let resourceOptions = PHAssetResourceRequestOptions()
            resourceOptions.isNetworkAccessAllowed = true

            let resources = PHAssetResource.assetResources(for: item.asset)
            guard let resource = resources.first else {
                dispatchGroup.leave()
                continue
            }

            let fileExtension = resource.uniformTypeIdentifier.contains("video") ? ".mov" : ".jpg"
            let filename = String(format: "media_%03d%@", index, fileExtension)
            let outputURL = exportFolder.appendingPathComponent(filename)

            PHAssetResourceManager.default().writeData(for: resource, toFile: outputURL, options: resourceOptions) { error in
                if let error = error {
                    print("❌ Failed to export: \(error)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            let zipURL = tempDir.appendingPathComponent("RegionExport.zip")
            try? fileManager.removeItem(at: zipURL)
            do {
                try fileManager.zipItem(at: exportFolder, to: zipURL)
                let activityVC = UIActivityViewController(activityItems: [zipURL], applicationActivities: nil)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(activityVC, animated: true)
                }
            } catch {
                print("❌ Zip failed: \(error)")
            }
        }
    }
}
