import SwiftUI
import Photos
import CoreLocation
import CoreNFC

struct ScanView: View {
    @State private var showingPermissionAlert = false
    @State private var showLazioMedia = false
    @State private var fetchedMedia: [MediaItem] = []
    @State private var selectedItem: MediaItem? = nil
    @State private var showFullScreenGallery = false
    @EnvironmentObject var mediaManager: MediaManager
    @EnvironmentObject var journalStore: JournalStore // ✅ ADDED
    @State private var generatedJournalEntry: String? = nil
    @State private var isGenerating = false
    @State private var showJournalChoice = false
    @State private var selectedAsset: PHAsset? = nil
    @State private var showFullscreen = false

    @State private var scannedTagID: String? = nil
    @State private var showMapPicker: Bool = false
    @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
    @State private var selectedCity: String = ""
    @State private var selectedRegion: String = ""

    @StateObject private var nfcState = NFCWrapper()

    class NFCWrapper: ObservableObject {
        var handler: NFCDelegateHandler?
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Tap to simulate NFC scan")
                .padding(.top)

            Button("Scan Lazio (Rome)") {
                simulateScan(forRegion: "Lazio", city: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.89, longitude: 12.5))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Scan Braunschweig") {
                simulateScan(forRegion: "Lower Saxony", city: "Braunschweig", coordinate: CLLocationCoordinate2D(latitude: 52.264, longitude: 10.524))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Scan NFC Tag") {
                startNFCScan()
            }
            .padding()

            .alert(isPresented: $showingPermissionAlert) {
                Alert(
                    title: Text("Lazio NFC Tag Detected"),
                    message: Text("Allow upload of media taken in Lazio, Italy?"),
                    primaryButton: .default(Text("Allow")) {
                        simulateScan(forRegion: "Lazio", city: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.89, longitude: 12.5))
                    },
                    secondaryButton: .cancel()
                )
            }

            if showLazioMedia {
                if fetchedMedia.isEmpty {
                    Text("No media found.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    Text("Media from \(selectedCity)")
                        .font(.headline)
                        .padding(.top)

                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                            ForEach(fetchedMedia.indices, id: \.self) { index in
                                let item = fetchedMedia[index]
                                PhotoThumbnailView(item: item)
                                    .onTapGesture {
                                        selectedAsset = item.asset
                                        showFullscreen = true
                                    }
                            }
                        }
                        .padding()
                    }

                    // Journal entry generation button
                    Button("✨ Generate Journal Entry") {
                        showJournalChoice = true
                    }
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .actionSheet(isPresented: $showJournalChoice) {
                        ActionSheet(
                            title: Text("Create Journal Entry"),
                            message: Text("How would you like to create your journal?"),
                            buttons: [
                                .default(Text("Write it myself")) {
                                    generatedJournalEntry = ""
                                },
                                .default(Text("Let AI write a draft")) {
                                    generateJournalEntry()
                                },
                                .cancel()
                            ]
                        )
                    }

                    // Editable Journal TextEditor
                    if let _ = generatedJournalEntry {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📝 Journal Entry")
                                .font(.title3)
                                .bold()

                            TextEditor(text: Binding(
                                get: { generatedJournalEntry ?? "" },
                                set: { generatedJournalEntry = $0 }
                            ))
                            .frame(height: 180)
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)

                            // ✅ Save Button
                            Button("💾 Save Entry") {
                                saveJournalEntry()
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding()
        .fullScreenCover(isPresented: $showFullscreen) {
            if let asset = selectedAsset {
                ZoomableImageView(asset: asset)
            } else {
                Text("No media to show")
                    .foregroundColor(.white)
                    .background(Color.black.ignoresSafeArea())
            }
        }
    }

    func simulateScan(forRegion region: String, city: String, coordinate: CLLocationCoordinate2D) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                let fetchOptions = PHFetchOptions()
                let allPhotos = PHAsset.fetchAssets(with: fetchOptions)
                var matchingMedia: [MediaItem] = []

                allPhotos.enumerateObjects { asset, _, _ in
                    if let location = asset.location {
                        let distance = location.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
                        if distance < 100_000 {
                            let mediaItem = MediaItem(
                                asset: asset,
                                region: region,
                                city: city,
                                location: asset.location
                            )
                            matchingMedia.append(mediaItem)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.selectedCity = city
                    self.selectedRegion = region
                    self.selectedCoordinate = coordinate
                    self.fetchedMedia = matchingMedia
                    self.showLazioMedia = true
                    self.mediaManager.updateMedia(region: region, city: city, media: matchingMedia)
                    NotificationCenter.default.post(name: .mediaUpdatedForRegion, object: region)
                }
            }
        }
    }

    func startNFCScan() {
        let handler = NFCDelegateHandler(
            onTagScanned: { tagID in
                DispatchQueue.main.async {
                    print("✅ Tag ID: \(tagID)")
                    self.scannedTagID = tagID
                    self.showMapPicker = true
                }
            },
            onTimeout: {
                DispatchQueue.main.async {
                    print("⌛️ NFC scan timed out")
                }
            }
        )

        nfcState.handler = handler
        let session = NFCNDEFReaderSession(delegate: handler, queue: nil, invalidateAfterFirstRead: true)
        session.alertMessage = "Hold your iPhone near the tag."
        session.begin()
    }

    // GPT-based AI generation
    func generateJournalEntry() {
        let gpt = GPTService()
        let prompt = "Write a short travel journal entry based on this trip to \(selectedCity) in \(selectedRegion). Make it emotional, visual, and poetic. The user visited local streets, took photos, and enjoyed quiet moments."

        generatedJournalEntry = nil
        gpt.generateJournalEntry(prompt: prompt) { response in
            if let response = response {
                generatedJournalEntry = response
            } else {
                generatedJournalEntry = "⚠️ Failed to generate journal. Please try again."
            }
        }
    }

    func saveJournalEntry() {
        guard let text = generatedJournalEntry,
              !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("Cannot save: journal is empty.")
            return
        }

        let block = JournalBlock.text(id: UUID(), content: text)
        let entry = JournalEntry(
            title: "Entry in \(selectedCity)",
            region: selectedRegion,
            blocks: [block]
        )

        journalStore.add(entry)
        generatedJournalEntry = nil
        print("✅ Journal entry saved for region: \(selectedRegion)")
    }
}

extension Notification.Name {
    static let mediaUpdatedForRegion = Notification.Name("mediaUpdatedForRegion")
}
