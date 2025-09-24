

import Foundation
import SwiftUI

struct JournalPlaceholderView: View {
    @State private var selectedRegion: String = "All"
    @State private var availableRegions: [String] = ["All", "Lazio", "Braunschweig"]
    @State private var selectedItem: MediaItem? = nil
    @State private var showFullScreen = false
    @State private var showEditor = false

    @EnvironmentObject var mediaManager: MediaManager

    var mediaByRegion: [String: [MediaItem]] {
        mediaManager.cityGroupedMedia.mapValues { $0.values.flatMap { $0 } }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Region selector pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(availableRegions, id: \.self) { region in
                            Button(action: {
                                selectedRegion = region
                            }) {
                                Text(region)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 14)
                                    .background(selectedRegion == region ? Color.green : Color(.systemGray6))
                                    .foregroundColor(selectedRegion == region ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }

                        Button(action: {
                            // Optional: open region selector
                        }) {
                            Image(systemName: "plus")
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray5))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }

                if selectedMedia.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "book")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No journal entries found")
                            .foregroundColor(.gray)
                        Button(action: {
                            showEditor = true
                        }) {
                            Label("Create New Entry", systemImage: "plus")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(.horizontal, 40)
                        }
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                            ForEach(selectedMedia) { item in
                                PhotoThumbnailView(item: item) { tapped in
                                    selectedItem = tapped
                                    showFullScreen = true
                                }
                            }
                        }
                        .padding()
                    }

                    Button(action: {
                        showEditor = true
                    }) {
                        Label("Create New Entry", systemImage: "plus")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Travel Journal")
            .background(Color(.systemBackground))
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            if let selected = selectedItem {
                FullScreenGalleryView(mediaItems: selectedMedia, currentItem: selected)
            }
        }
        .sheet(isPresented: $showEditor) {
            CreateNewEntryView(region: selectedRegion, media: selectedMedia)
        }
    }

    var selectedMedia: [MediaItem] {
        if selectedRegion == "All" {
            return mediaByRegion.values.flatMap { $0 }
        } else {
            return mediaByRegion[selectedRegion] ?? []
        }
    }
}
