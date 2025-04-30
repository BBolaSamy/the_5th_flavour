//
//  RegionMediaView.swift
//  NFC_TagDetector
//
//  Created by George Saleip on 22.04.25.
//

import SwiftUI
import PhotosUI

struct IdentifiableAsset: Identifiable {
    let id = UUID()
    let asset: PHAsset
}


struct RegionMediaView: View {
    @Binding var items: [MediaItem]
    @Binding var isPresented: Bool

    @State private var selectedAsset: IdentifiableAsset?
    
    @State private var selectedAssetForDetail: IdentifiableAsset?

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero


    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(alignment: .center) {
                // Back Button
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 12)

                    Spacer()
                }

                if items.isEmpty {
                    Text("No media available for this region.")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(items) { item in
                                PhotoThumbnailView(asset: item.asset) { _ in
                                    selectedAssetForDetail = IdentifiableAsset(asset: item.asset)
                                }
                            }
                        }
                        .padding(8)
                    }
                }
            }
        }
        .fullScreenCover(item: $selectedAssetForDetail) { wrapper in
            MediaDetailView(item: MediaItem(asset: wrapper.asset, region: ""))
        }
    }
}
