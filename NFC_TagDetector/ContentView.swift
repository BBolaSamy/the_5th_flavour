//
//  ContentView.swift
//  NFC_TagDetector
//
//  Created by George Saleip on 22.04.25.
//
import PhotosUI
import SwiftUI
import Photos
import CoreLocation

struct ContentView: View {
    @State private var selectedRegionMedia: [MediaItem] = []
    @State private var showingRegionMedia = false
    @State private var groupedMedia = [String: [MediaItem]]()
    @State private var log = "Fetching photos..."
    @State private var isPickerPresented = false

    var body: some View {
        ZStack {
            // Background
            Color(hex: "#3E4C41")
                    .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()
                
                // App Logo and Title
                VStack {
                    Image("#426B68-4")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding(.bottom, 10)

                }

                // Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        print("Grouped Media Keys: \(groupedMedia.keys)")
                        if let media = groupedMedia["Lazio"] {
                            print("📸 Simulated NFC Scan → Lazio has \(media.count) media items")
                            DispatchQueue.main.async {
                                selectedRegionMedia = media
                                showingRegionMedia = true
                            }
                        } else {
                            print("⚠️ No media found for Lazio")
                        }
                    }) {
                        Text("SCAN Lazio Rome")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 8)
                    }
                    
                    Button(action: {
                        print("Grouped Media Keys: \(groupedMedia.keys)")
                        if let media = groupedMedia["Lower Saxony"] {
                            print("📸 Simulated NFC Scan → Lower Saxony has \(media.count) media items")
                            DispatchQueue.main.async {
                                selectedRegionMedia = media
                                showingRegionMedia = true
                            }
                        } else {
                            print("⚠️ No media found for Lower Saxony")
                        }
                    }) {
                        Text("SCAN Lower Saxony BS")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 8)
                    }

                    Button("➕ Add New Media") {
                        isPickerPresented = true
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 30)

                Spacer()

                // Debug log at bottom
                ScrollView {
                    //Text(log)
                    //  .font(.caption)
                    //  .foregroundColor(.gray)
                    //  .padding()
                }
                .frame(maxHeight: 180)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .fullScreenCover(isPresented: $showingRegionMedia) {
            RegionMediaView(items: $selectedRegionMedia, isPresented: $showingRegionMedia)
        }
        .photosPicker(isPresented: $isPickerPresented, selection: .constant(nil))
        .onAppear(perform: fetchPhotosWithLocation)
    }

    func fetchPhotosWithLocation() {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    log = "Photo access denied."
                }
                return
            }

            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            let imageAssets = PHAsset.fetchAssets(with: .image, options: options)
            let videoAssets = PHAsset.fetchAssets(with: .video, options: options)

            var allAssets: [PHAsset] = []
            imageAssets.enumerateObjects { asset, _, _ in allAssets.append(asset) }
            videoAssets.enumerateObjects { asset, _, _ in allAssets.append(asset) }

            processAssets(allAssets, index: 0)
        }
    }

    func processAssets(_ assets: [PHAsset], index: Int) {
        guard index < assets.count else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("📦 Final grouped media:")
                for (region, items) in groupedMedia {
                    print("→ \(region): \(items.count) item(s)")
                }
            }
            return
        }

        let asset = assets[index]
        if let location = asset.location {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                let region = placemarks?.first?.administrativeArea ?? "Unknown"
                let item = MediaItem(asset: asset, region: region)

                DispatchQueue.main.async {
                    groupedMedia[region, default: []].append(item)
                    log += "📍 (\(location.coordinate.latitude), \(location.coordinate.longitude)) → Region: \(region)\n"
                }

                DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                    processAssets(assets, index: index + 1)
                }
            }
        } else {
            DispatchQueue.main.async {
                log += "🖼️ Photo has no location data.\n"
            }

            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                processAssets(assets, index: index + 1)
            }
        }
    }
}
