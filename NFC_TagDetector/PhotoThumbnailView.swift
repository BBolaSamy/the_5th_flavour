//
//  PhotoThumbnailView.swift
//  NFC_TagDetector
//
//  Created by George Saleip on 22.04.25.
//

import SwiftUI
import Photos
import AVKit

struct PhotoThumbnailView: View {
    let asset: PHAsset
    var onImageTap: ((UIImage) -> Void)? = nil

    @State private var image: UIImage?
    @State private var isPresentingVideo = false
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width / 3 - 16,
                           height: UIScreen.main.bounds.width / 3 - 16)
                    .clipped()
                    .cornerRadius(6)
                    .overlay(
                        Group {
                            if asset.mediaType == .video {
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
                        if asset.mediaType == .video {
                            playVideo()
                        } else if let onImageTap = onImageTap {
                            onImageTap(image)
                        }
                    }

            } else {
                ProgressView("Loading...")
                    .frame(width: UIScreen.main.bounds.width / 3 - 16,
                           height: UIScreen.main.bounds.width / 3 - 16)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
                    .onAppear {
                        loadImage()
                    }
            }
        }
        .fullScreenCover(isPresented: $isPresentingVideo) {
            if let player = player {
                ZStack {
                    Color.black.ignoresSafeArea()
                    VideoPlayer(player: player)
                        .onAppear {
                            player.play()
                        }
                        .onDisappear {
                            player.pause()
                        }
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                player.pause()
                                isPresentingVideo = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    private func loadImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false

        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 300, height: 300),
                             contentMode: .aspectFill,
                             options: options) { result, _ in
            DispatchQueue.main.async {
                self.image = result
            }
        }
    }

    private func playVideo() {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
            if let urlAsset = avAsset as? AVURLAsset {
                DispatchQueue.main.async {
                    self.player = AVPlayer(url: urlAsset.url)
                    self.isPresentingVideo = true
                }
            }
        }
    }
}
