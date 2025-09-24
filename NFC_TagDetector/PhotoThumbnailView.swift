import SwiftUI
import Photos
import AVKit

struct PhotoThumbnailView: View {
    let item: MediaItem
    var onTap: ((MediaItem) -> Void)? = nil

    @State private var image: UIImage?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                        .cornerRadius(6)
                        .overlay(
                            Group {
                                if item.isVideo {
                                    Image(systemName: "play.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.white)
                                        .shadow(radius: 5)
                                }
                            },
                            alignment: .center
                        )
                        .onTapGesture {
                            onTap?(item)
                        }

                    if item.isVideo {
                        Text(formatDuration(item.duration))
                            .font(.caption2)
                            .bold()
                            .padding(4)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            .padding(6)
                    }
                } else {
                    ZStack {
                        Color.gray.opacity(0.2)
                        ProgressView()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .cornerRadius(6)
                    .onAppear {
                        loadImage(targetSize: CGSize(width: geometry.size.width * 2, height: geometry.size.width * 2))
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func loadImage(targetSize: CGSize) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false

        manager.requestImage(for: item.asset,
                             targetSize: targetSize,
                             contentMode: .aspectFill,
                             options: options) { result, _ in
            DispatchQueue.main.async {
                self.image = result
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
