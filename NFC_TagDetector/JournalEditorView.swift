import SwiftUI
import Photos

struct JournalEditorView: View {
    let region: String
    let initialMedia: [MediaItem]

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var journalStore: JournalStore

    @State private var blocks: [JournalBlock] = []
    @State private var title: String = ""
    @State private var detectedFaces: [DetectedFace] = []
    @State private var selectedFaceIndex: Int? = nil
    @State private var showNamePrompt = false
    @State private var nameInput = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TextField("Title (optional)", text: $title)
                        .font(.title2)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    // 🧠 Show detected faces once at the top (place this before your ForEach)
                    if !detectedFaces.isEmpty {
                        Text("Detected Faces:")
                            .font(.headline)
                            .padding(.top)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(detectedFaces.enumerated()), id: \.element.id) { index, face in
                                    VStack {
                                        Image(uiImage: face.image)
                                            .resizable()
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                            .onTapGesture {
                                                selectedFaceIndex = index
                                                nameInput = face.name ?? ""
                                                showNamePrompt = true
                                            }

                                        if let name = face.name {
                                            Text(name)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // 📝 Your original blocks loop — unchanged except face UI removed
                    ForEach(Array(blocks.enumerated()), id: \.element.id) { index, block in
                        VStack(spacing: 8) {

                            switch block {
                            case .media(_, let id, let isVideo):
                                if let asset = fetchAsset(with: id) {
                                    if isVideo {
                                        VideoPlayerView(asset: asset)
                                            .frame(height: 200)
                                            .cornerRadius(10)
                                    } else {
                                        PhotoThumbnailView(item: MediaItem(asset: asset, region: region, city: "", location: nil))
                                            .frame(height: 200)
                                            .cornerRadius(10)
                                    }
                                } else {
                                    Text("⚠️ Media not found.")
                                        .foregroundColor(.red)
                                        .frame(height: 200)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(10)
                                }


                            case .text(_, let text):
                                TextEditor(text: Binding(
                                    get: { text },
                                    set: { newText in blocks[index] = .text(id: block.id, content: newText) }
                                ))
                                .frame(minHeight: 100)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }

                            HStack {
                                Button("➕ Text Below") {
                                    blocks.insert(.text(id: UUID(), content: ""), at: index + 1)
                                }
                                Spacer()
                                Button(role: .destructive) {
                                    blocks.remove(at: index)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                            .padding(.horizontal)
                        }
                    }


                    Button("✨ Generate Text with AI") {
                        generateAIJournal()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)

                    Spacer(minLength: 50)
                }
                .padding(.vertical)
            }
            .navigationTitle("Edit Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                        dismiss()
                    }
                }
            }
            
            .alert("Who is this?", isPresented: $showNamePrompt, actions: {
                TextField("Enter name", text: $nameInput)
                Button("Save") {
                    if let index = selectedFaceIndex {
                        detectedFaces[index].name = nameInput
                    }
                }
                Button("Cancel", role: .cancel) { }
            })

            .onAppear {
                blocks = initialMedia.map {
                    .media(id: UUID(), mediaIdentifier: $0.asset.localIdentifier, isVideo: $0.isVideo)
                }
            }
        }
    }

    private func fetchAsset(with identifier: String) -> PHAsset? {
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject

        if asset == nil {
            print("❌ Could not find PHAsset for identifier: \(identifier)")
        } else {
            print("✅ Found PHAsset for identifier: \(identifier)")
        }

        return asset
    }



    
    private func saveEntry() {
        let entry = JournalEntry(
            title: title.isEmpty ? "Untitled Entry" : title,
            region: region,
            blocks: blocks
        )

        journalStore.add(entry)
    }

    private func generateAIJournal() {
        guard let firstMedia = initialMedia.first else { return }

        fetchFullImage(for: firstMedia.asset) { uiImage in
            guard let uiImage = uiImage else { return }

            let creationDate = firstMedia.asset.creationDate ?? Date()
            let formattedDate = formatSmartDate(from: creationDate)
            let assetLocation = firstMedia.asset.location

            // Calculate time of day and month
            let hour = Calendar.current.component(.hour, from: creationDate)
            let timeOfDay: String = {
                switch hour {
                case 6..<11: return "morning"
                case 11..<17: return "afternoon"
                case 17..<21: return "evening"
                default: return "night"
                }
            }()
            let month = DateFormatter().apply { $0.dateFormat = "LLLL" }.string(from: creationDate)

            // 1. Scene Detection
            SceneAnalyzer.classifyScene(from: uiImage) { scene in
                let sceneDescription = scene ?? "unknown scene"
                print("📸 Scene: \(sceneDescription)")

                // 2. People Count
                PersonDetector.detectFaces(in: uiImage) { faceCount in
                    print("🧍‍♂️ Detected \(faceCount) person(s)")

                    let peopleText: String
                    switch faceCount {
                    case 0: peopleText = "nobody visible"
                    case 1: peopleText = "just me"
                    case 2: peopleText = "me and one other person"
                    default: peopleText = "me and \(faceCount - 1) others"
                    }

                    // 3. Object Recognition
                    ObjectRecognizer.detectObjects(in: uiImage) { detectedObjects in
                        let allObjectsSummary = detectedObjects.joined(separator: ", ")
                        let foodKeywords = ["pizza", "coffee", "drink", "juice", "cup", "bottle", "food", "dessert", "plate"]
                        let foodMentions = detectedObjects.filter { foodKeywords.contains($0.lowercased()) }

                        let sceneInput = foodMentions.isEmpty
                            ? sceneDescription
                            : "\(sceneDescription), enjoying \(foodMentions.joined(separator: " and "))"

                        print("🧠 Objects: \(allObjectsSummary)")

                        // 4. Reverse Geocode
                        if let location = assetLocation {
                            resolveLocationName(from: location) { locationName in

                                // ✅ Finalized, focused GPT prompt
                                let prompt = """
                                You are a 28-year-old woman revisiting her travel journal. You're looking at a photo you took in \(locationName), trying to remember and document the moment honestly and vividly.

                                ### Photo Details:
                                - 📍 Location: \(locationName)
                                - 🕰️ Time of day: \(timeOfDay)
                                - 📅 Month: \(month)
                                - 🧍 People visible: \(peopleText)
                                - 📸 Objects seen: \(allObjectsSummary)
                                - 🖼️ Scene description: \(sceneInput)

                                ### Your Task:
                                Write a realistic, first-person journal entry based on this photo.

                                DO NOT:
                                - Write poetry
                                - Use abstract metaphors or romantic travel clichés
                                - Say anything like "whispers of time" or "soul at peace"
                                - Invent things not present in the photo

                                DO:
                                - Describe the photo as if you’re showing it to a close friend
                                - Mention at least two of the objects
                                - Include how the moment felt (tired, happy, lost, etc.)
                                - Be vulnerable, specific, and human

                                ### Example Start:
                                "I was sitting outside a café when I snapped this photo. You can see the pizza crust on the plate and my coffee just starting to cool down..."

                                Now write the entry:
                                """

                                print("🧠 GPT Prompt:\n\(prompt)")

                                // 6. Send to GPT
                                GPTService().generateJournalEntry(prompt: prompt) { journalText in
                                    if let journalText = journalText {
                                        DispatchQueue.main.async {
                                            print("📝 AI Journal Entry:\n\(journalText)")
                                            blocks.insert(.text(id: UUID(), content: journalText), at: 0)
                                        }
                                    }
                                }
                            }
                        }

                        // 7. Face Thumbnails (Optional)
                        FaceDetectionService.detectFaces(in: uiImage) { faces in
                            DispatchQueue.main.async {
                                detectedFaces = faces
                                print("🧠 Found \(faces.count) face(s).")
                            }
                        }
                    }
                }
            }
        }
    }

    
    private func fetchUIImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat

        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 512, height: 512),
                             contentMode: .aspectFit,
                             options: options) { image, _ in
            completion(image)
        }
    }
    
    private func fetchFullImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.resizeMode = .none

        let manager = PHImageManager.default()
        manager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .default,
            options: options
        ) { image, _ in
            completion(image)
        }
    }


    private func resolveLocationName(from location: CLLocation, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let place = placemarks?.first {
                let name = [place.name, place.locality, place.country]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                completion(name)
            } else {
                completion("Unknown location")
            }
        }
    }
    
    private func formatSmartDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Full day name (e.g., Sunday)
        let dayOfWeek = formatter.string(from: date)

        formatter.dateFormat = "MMMM d"
        let monthDay = formatter.string(from: date)

        let daySuffix = daySuffixFromCalendarDay(date)

        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)

        formatter.dateFormat = "h:mm a"
        let time = formatter.string(from: date)

        return "\(dayOfWeek) afternoon, \(monthDay)\(daySuffix), \(year) at \(time)"
    }

    
    private func daySuffixFromCalendarDay(_ date: Date) -> String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        switch day {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
    
    

}
