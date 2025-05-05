//
//  VideoPlayerView.swift
//  NFC_TagDetector
//
//  Created by George Saleip on 30.04.25.
//

import SwiftUI
import AVKit
import Photos

struct VideoPlayerView: View {
    let asset: PHAsset

    @State private var player: AVPlayer?
    @State private var isLoading = true
    @State private var loadError = false

    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.seek(to: .zero)
                        player.play()
                    }
                    .ignoresSafeArea()
            } else if isLoading {
                ProgressView("Loading video...")
                    .foregroundColor(.white)
                    .background(Color.black.ignoresSafeArea())
            } else if loadError {
                VStack {
                    Text("⚠️ Failed to load video.")
                        .foregroundColor(.white)
                    Button("Retry") {
                        isLoading = true
                        loadError = false
                        loadVideo()
                    }
                    .padding()
                }
                .background(Color.black.ignoresSafeArea())
            }
        }
        .onAppear(perform: loadVideo)
    }

    private func loadVideo() {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true

        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, error in
            if let error = error {
                print("❌ Error loading video asset: \(String(describing: error))")
            }

            guard let urlAsset = avAsset as? AVURLAsset else {
                DispatchQueue.main.async {
                    self.loadError = true
                    self.isLoading = false
                }
                return
            }

            let playerItem = AVPlayerItem(asset: urlAsset)
            DispatchQueue.main.async {
                self.player = AVPlayer(playerItem: playerItem)
                self.isLoading = false
            }
        }
    }
}
