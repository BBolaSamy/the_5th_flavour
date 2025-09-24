

import SwiftUI
import PhotosUI
import Photos

struct MediaDetailView: View {
    let item: MediaItem
    
    @State private var fullImage: UIImage? = nil
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let fullImage {
                Image(uiImage: fullImage)
                    .resizable()
                    .scaledToFit()
            } else if isLoading {
                ProgressView("Loading image...")
                    .foregroundColor(.white)
            } else {
                Text("Failed to load image")
                    .foregroundColor(.white)
            }
        }
        .task {
            loadImage()
        }
    }
    

    private func loadImage() {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true // ✅ important for iCloud-based assets

        PHImageManager.default().requestImage(
            for: item.asset,
            targetSize: PHImageManagerMaximumSize, // get full image
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                fullImage = image
                isLoading = false
            }
        }
    }
}
