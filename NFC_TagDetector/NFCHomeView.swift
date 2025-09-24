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
import Combine
import CoreNFC

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("lastSyncDate") private var lastSyncDate: Double = 0
    @State private var cityGroupedMedia = [String: [String: [MediaItem]]]() // [Province: [City: [Items]]]
    @State private var selectedProvince = ""
    @State private var selectedCityMedia: [MediaItem] = []
    @State private var showingCityList = false
    @State private var showingRegionMedia = false
    @State private var isPickerPresented = false
    @AppStorage("autoSyncEnabled") var autoSyncEnabled: Bool = true
    @State private var log = ""
    @State private var isScanning = false

    var body: some View {
        ZStack {
            Color(hex: "#3E4C41").ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                Image("#426B68-4")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)

                VStack(spacing: 16) {
                    Button("📡 Scan NFC Tag") {
                        startNFCScan()
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.85))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 8)


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

                ScrollView {
                    Text(log)
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding()
                }
                .frame(maxHeight: 140)
                .background(Color.black.opacity(0.2))
                .cornerRadius(10)
                .padding()
            }
        }
        .fullScreenCover(isPresented: $isScanning) {
            ZStack {
                Color.black.opacity(0.8).ignoresSafeArea()
                VStack(spacing: 20) {
                    ProgressView("Scanning NFC Tag...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                        .font(.headline)
                    Button("Cancel") {
                        isScanning = false
                    }
                    .foregroundColor(.red)
                }
            }
        }

        .fullScreenCover(isPresented: $showingRegionMedia) {
            RegionMediaView(items: $selectedCityMedia, isPresented: $showingRegionMedia)
        }
        .photosPicker(isPresented: $isPickerPresented, selection: .constant(nil))
        .onAppear {
            if autoSyncEnabled {
                fetchPhotosWithLocation()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active && autoSyncEnabled {
                fetchPhotosWithLocation()
            }
        }
    }

    // MARK: - UI

    
    func startNFCScan() {
        guard NFCNDEFReaderSession.readingAvailable else {
            log += "❌ NFC not available on this device.\n"
            return
        }

        isScanning = true
        var hasDetected = false

        let session = NFCNDEFReaderSession(delegate: NFCDelegateHandler(
            onTagScanned: { tagID in
                hasDetected = true
                DispatchQueue.main.async {
                    isScanning = false
                    if let region = NFCTagRegistry.tagToRegion[tagID] {
                        selectedProvince = region
                        if let cities = cityGroupedMedia[region], !cities.isEmpty {
                            showingCityList = true
                        } else {
                            log += "⚠️ No media found for scanned region: \(region).\n"
                        }
                    } else {
                        log += "⚠️ Unknown NFC tag: \(tagID).\n"
                    }
                }
            },
            onTimeout: {
                if !hasDetected {
                    DispatchQueue.main.async {
                        log += "⌛ No NFC tag detected after 15 seconds.\n"
                        isScanning = false
                    }
                }
            }
        ), queue: nil, invalidateAfterFirstRead: true)

        session.alertMessage = "Hold your iPhone near the NFC tag."
        session.begin()
    }


    
    func scanButton(for province: String) -> some View {
        Button(action: {
            selectedProvince = province
            if let cities = cityGroupedMedia[province], !cities.isEmpty {
                showingCityList = true
            } else {
                log += "⚠️ No media found for \(province).\n"
            }
        }) {
            Text("SCAN \(province)")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 8)
        }
    }

    // MARK: - Fetch Media

    func fetchPhotosWithLocation() {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    log += "❌ Photo access denied.\n"
                }
                return
            }

            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(
                format: "(mediaType == %d || mediaType == %d)",
                PHAssetMediaType.image.rawValue,
                PHAssetMediaType.video.rawValue
            )

            let assets = PHAsset.fetchAssets(with: fetchOptions)
            var fetchedAssets: [PHAsset] = []
            assets.enumerateObjects { asset, _, _ in
                fetchedAssets.append(asset)
            }

            DispatchQueue.main.async {
                if !fetchedAssets.isEmpty {
                    log += "📥 Found \(fetchedAssets.count) media item(s)...\n"

                    // ✅ Clear old data to avoid duplication
                    cityGroupedMedia.removeAll()

                    processAssets(fetchedAssets, index: 0)
                    lastSyncDate = Date().timeIntervalSince1970
                } else {
                    log += "⚠️ No media items found in Photos library.\n"
                }
            }
        }
    }

    func processAssets(_ assets: [PHAsset], index: Int) {
        guard index < assets.count else {
            log += "✅ Grouping complete.\n"
            return
        }

        let asset = assets[index]

        if let location = asset.location {
            let geocoder = CLGeocoder()

            // Add a delay between requests (1.2 seconds)
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.2 * Double(index)) {
                geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    let placemark = placemarks?.first
                    let region = placemark?.administrativeArea ?? "Unknown"
                    let city = placemark?.locality ?? "Unknown"
                    let item = MediaItem(asset: asset, region: region, city: city)

                    DispatchQueue.main.async {
                        cityGroupedMedia[region, default: [:]][city, default: []].append(item)
                        log += "📍 \(region), \(city)\n"
                    }

                    // Call next asset (no need for asyncAfter again — already throttled)
                    processAssets(assets, index: index + 1)
                }
            }
        } else {
            DispatchQueue.main.async {
                log += "❌ Asset has no location info.\n"
            }

            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                processAssets(assets, index: index + 1)
            }
        }
    }
}
