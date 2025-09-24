import SwiftUI
import AVKit
import Photos

struct FullScreenGalleryView: View {
    let mediaItems: [MediaItem]
    let currentItem: MediaItem

    @Environment(\.dismiss) var dismiss
    @State private var selectedIndex: Int = 0

    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(mediaItems.indices, id: \.self) { index in
                let item = mediaItems[index]
                ZStack {
                    if item.isImage {
                        ImageView(asset: item.asset)
                    } else if item.isVideo {
                        VideoPlayerView(asset: item.asset)
                    }
                }
                .tag(index)
                .ignoresSafeArea()
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .background(Color.black)
        .onAppear {
            if let startIndex = mediaItems.firstIndex(where: { $0.asset.localIdentifier == currentItem.asset.localIdentifier }) {
                selectedIndex = startIndex
            }
        }
        .overlay(
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .padding()
            },
            alignment: .topTrailing
        )
    }
}
