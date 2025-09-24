

import SwiftUI
import AVKit
import Photos

struct VideoPlayerView: View {
    let asset: PHAsset
    @State private var player: AVPlayer?

    var body: some View {
        Group {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                ProgressView()
                    .onAppear {
                        loadVideo()
                    }
            }
        }
    }

    private func loadVideo() {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat

        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
            if let urlAsset = avAsset as? AVURLAsset {
                DispatchQueue.main.async {
                    self.player = AVPlayer(url: urlAsset.url)
                }
            }
        }
    }
}
