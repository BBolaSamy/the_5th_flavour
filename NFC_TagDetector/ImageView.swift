

import Foundation
import SwiftUI
import Photos

struct ImageView: View {
    let asset: PHAsset
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .onAppear {
                        fetchImage()
                    }
            }
        }
    }

    private func fetchImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat

        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 2000, height: 2000),
                             contentMode: .aspectFit,
                             options: options) { result, _ in
            self.image = result
        }
    }
}
