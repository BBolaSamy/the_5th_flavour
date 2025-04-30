//
//  FullScreenGalleryView.swift
//  NFC_TagDetector
//
//  Created by George Saleip on 30.04.25.
//

import SwiftUI
import Photos
import AVKit

struct FullScreenGalleryView: View {
    let mediaItems: [MediaItem]
    @State var currentIndex: Int

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(mediaItems.indices, id: \.self) { index in
                let item = mediaItems[index]

                ZStack {
                    if item.asset.mediaType == .video {
                        VideoPlayerView(asset: item.asset)
                    } else {
                        ZoomableImageView(asset: item.asset)
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .background(Color.black.ignoresSafeArea())
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}
