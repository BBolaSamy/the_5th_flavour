import SwiftUI
import Photos

struct AssetThumbnailView: View {
    let asset: PHAsset
    @State private var image: UIImage? = nil

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .onAppear {
            requestThumbnail()
        }
    }

    private func requestThumbnail() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast

        manager.requestImage(
            for: asset,
            targetSize: CGSize(width: 200, height: 200),
            contentMode: .aspectFill,
            options: options
        ) { result, _ in
            self.image = result
        }
    }
}
