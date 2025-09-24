import SwiftUI
import Photos

struct ZoomableImageView: View {
    let asset: PHAsset
    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage? = nil

    var body: some View {
        NavigationView {
            Group {
                if let image = image {
                    ScrollView([.horizontal, .vertical]) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                } else {
                    ProgressView("Loading...")
                }
            }
            .navigationTitle("Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.resizeMode = .none

        manager.requestImage(for: asset,
                             targetSize: PHImageManagerMaximumSize,
                             contentMode: .aspectFit,
                             options: options) { image, _ in
            self.image = image
        }
    }
}
