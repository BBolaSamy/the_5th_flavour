import SwiftUI

struct JournalCreationView: View {
    @State private var gptService = GPTService()
    @State private var journalStore = JournalStore()
    @State private var selectedMedia: [MediaItem]
    @State private var cityName: String
    @State private var showingCreationOptions = true
    @State private var journalContent = ""
    @State private var isGenerating = false
    @State private var showingEditor = false
    @State private var journalTitle = ""
    @State private var selectedTone = "reflective"
    
    let onSave: (JournalEntry) -> Void
    
    init(selectedMedia: [MediaItem], cityName: String, onSave: @escaping (JournalEntry) -> Void) {
        self._selectedMedia = State(initialValue: selectedMedia)
        self._cityName = State(initialValue: cityName)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if showingCreationOptions {
                    // Creation Options
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Create Journal Entry")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("for \(cityName)")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Text("\(selectedMedia.count) photos selected")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)
                        
                        Spacer()
                        
                        // Creation Options
                        VStack(spacing: 16) {
                            Text("How would you like to create your journal entry?")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            
                            JournalCreationOption(
                                title: "Generate with AI",
                                subtitle: "Let AI create a vivid memory from your photos",
                                icon: "sparkles",
                                color: .purple
                            ) {
                                generateWithAI()
                            }
                            
                            JournalCreationOption(
                                title: "Write your own",
                                subtitle: "Create a personal journal entry",
                                icon: "pencil",
                                color: .blue
                            ) {
                                showManualEditor()
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        Spacer()
                    }
                } else if isGenerating {
                    // AI Generation State
                    VStack(spacing: 24) {
                        Spacer()
                        
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                        
                        Text("Generating your memory...")
                            .font(.headline)
                        
                        Text("AI is analyzing your photos and creating a vivid journal entry")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                } else {
                    // Journal Editor
                    VStack(spacing: 0) {
                        // Title Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.headline)
                            
                            TextField("Enter journal title", text: $journalTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding()
                        
                        // Content Editor
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Content")
                                .font(.headline)
                            
                            TextEditor(text: $journalContent)
                                .frame(minHeight: 300)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding()
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Journal Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if showingCreationOptions {
                        Button("Cancel") {
                            // Dismiss
                        }
                    } else {
                        Button("Back") {
                            showingCreationOptions = true
                            isGenerating = false
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !showingCreationOptions && !isGenerating {
                        Button("Save") {
                            saveJournalEntry()
                        }
                        .disabled(journalTitle.isEmpty || journalContent.isEmpty)
                    }
                }
            }
        }
    }
    
    private func generateWithAI() {
        isGenerating = true
        showingCreationOptions = false
        
        // Build metadata from selected media
        let metadata = buildMetadataFromMedia()
        
        // Generate journal entry with AI
        gptService.generateEnrichedJournalEntry(from: metadata) { content in
            DispatchQueue.main.async {
                isGenerating = false
                if let content = content {
                    journalContent = content
                    journalTitle = "Memories from \(cityName)"
                    showingEditor = true
                } else {
                    // Show error and allow manual entry
                    journalContent = "Failed to generate AI content. Please write your own entry."
                    journalTitle = "Memories from \(cityName)"
                    showingEditor = true
                }
            }
        }
    }
    
    private func showManualEditor() {
        showingCreationOptions = false
        journalTitle = "Memories from \(cityName)"
        journalContent = ""
    }
    
    private func buildMetadataFromMedia() -> MediaMetadataSummary {
        let locations = selectedMedia.compactMap { $0.location }
        let dates = selectedMedia.compactMap { $0.asset.creationDate }
        
        let primaryLocation = locations.first?.coordinate
        let primaryDate = dates.first ?? Date()
        
        let detectedObjects = selectedMedia.flatMap { $0.detectedObjects }
        let uniqueObjects = Array(Set(detectedObjects))
        
        return MediaMetadataSummary(
            location: cityName,
            date: DateFormatter.localizedString(from: primaryDate, dateStyle: .medium, timeStyle: .short),
            people: "Friends and family", // This would be detected from face recognition
            scene: uniqueObjects.joined(separator: ", "),
            mood: "Joyful and memorable"
        )
    }
    
    private func saveJournalEntry() {
        let blocks: [JournalBlock] = [
            .text(id: UUID(), content: journalTitle),
            .text(id: UUID(), content: journalContent)
        ]
        
        let entry = JournalEntry(
            title: journalTitle,
            region: cityName,
            blocks: blocks
        )
        
        onSave(entry)
    }
}

struct JournalCreationOption: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    JournalCreationView(
        selectedMedia: [],
        cityName: "San Francisco"
    ) { _ in }
}
