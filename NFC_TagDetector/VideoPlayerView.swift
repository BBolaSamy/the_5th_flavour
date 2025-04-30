//
//  VideoPlayerView.swift
//  NFC_TagDetector
//
//  Created by George Saleip on 30.04.25.
//

import SwiftUI
import Photos
import AVKit

struct VideoPlayerView: View {
    let asset: PHAsset
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                ProgressView("Loading video...")
                    .foregroundColor(.white)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            loadVideo()
        }
    }

    private func loadVideo() {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic

        PHImageManager.default().requestPlayerItem(forVideo: asset, options: options) { playerItem, _ in
            if let item = playerItem {
                DispatchQueue.main.async {
                    self.player = AVPlayer(playerItem: item)
                }
            }
        }
    }
}
