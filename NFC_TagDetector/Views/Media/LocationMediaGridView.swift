import SwiftUI
import Photos
import CoreLocation

struct LocationMediaGridView: View {
    @StateObject private var mediaService = LocationBasedMediaService()
    @State private var selectedMedia: Set<MediaItem> = []
    @State private var showingPermissionAlert = false
    @State private var showingFullScreen = false
    @State private var selectedMediaItem: MediaItem?
    
    let coordinate: CLLocationCoordinate2D
    let cityName: String
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Photos near \(cityName)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Found \(mediaService.mediaItems.count) photos within 50km")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Permission Request
            if !mediaService.hasPhotoPermission {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("Photo Access Required")
                        .font(.headline)
                    
                    Text("We need access to your photos to find memories from this location")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Grant Access") {
                        Task {
                            await mediaService.requestPhotoPermission()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if mediaService.isLoading {
                // Loading State
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text("Finding your photos...")
                        .font(.headline)
                    
                    Text("Searching within 50km of \(cityName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if mediaService.mediaItems.isEmpty {
                // Empty State
                VStack(spacing: 16) {
                    Image(systemName: "photo")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No photos found")
                        .font(.headline)
                    
                    Text("No photos were found within 50km of \(cityName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Media Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(mediaService.mediaItems) { mediaItem in
                            MediaThumbnailView(
                                mediaItem: mediaItem,
                                isSelected: selectedMedia.contains(mediaItem)
                            ) {
                                if selectedMedia.contains(mediaItem) {
                                    selectedMedia.remove(mediaItem)
                                } else {
                                    selectedMedia.insert(mediaItem)
                                }
                            } onTap: {
                                selectedMediaItem = mediaItem
                                showingFullScreen = true
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Selection Actions
                if !selectedMedia.isEmpty {
                    VStack(spacing: 12) {
                        HStack {
                            Text("\(selectedMedia.count) selected")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button("Clear") {
                                selectedMedia.removeAll()
                            }
                            .foregroundColor(.red)
                        }
                        
                        HStack(spacing: 12) {
                            Button("Create Journal") {
                                // Navigate to journal creation
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)
                            
                            Button("Add to Trip") {
                                // Add to road trip
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                }
            }
        }
        .navigationTitle("Media")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await mediaService.fetchMediaNearLocation(coordinate: coordinate)
            }
        }
        .fullScreenCover(isPresented: $showingFullScreen) {
            if let mediaItem = selectedMediaItem {
                MediaDetailView(item: mediaItem)
            }
        }
    }
}

struct MediaThumbnailView: View {
    let mediaItem: MediaItem
    let isSelected: Bool
    let onToggleSelection: () -> Void
    let onTap: () -> Void
    
    @State private var thumbnailImage: UIImage?
    
    var body: some View {
        ZStack {
            // Thumbnail Image
            if let thumbnailImage = thumbnailImage {
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            }
            
            // Video Indicator
            if mediaItem.asset.mediaType == .video {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(8)
            }
            
            // Selection Overlay
            if isSelected {
                Rectangle()
                    .fill(Color.blue.opacity(0.3))
                    .overlay(
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    )
            }
            
            // Distance Badge
            if let distance = mediaItem.formattedDistance {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(distance)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                .padding(4)
            }
        }
        .cornerRadius(8)
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture {
            onToggleSelection()
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .opportunistic
        requestOptions.resizeMode = .exact
        
        let targetSize = CGSize(width: 200, height: 200)
        
        PHImageManager.default().requestImage(
            for: mediaItem.asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: requestOptions
        ) { image, _ in
            DispatchQueue.main.async {
                self.thumbnailImage = image
            }
        }
    }
}

#Preview {
    NavigationView {
        LocationMediaGridView(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            cityName: "San Francisco"
        )
    }
}
