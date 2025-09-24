import SwiftUI
import Photos

struct JournalDetailView: View {
    let entry: JournalEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let cover = firstAsset(for: entry) {
                    AssetThumbnailView(asset: cover)
                        .frame(height: 260)
                        .clipped()
                        .cornerRadius(20)
                        .overlay(
                            VStack {
                                Spacer()
                                HStack {
                                    Text(entry.title.isEmpty ? "Untitled Journal" : entry.title)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .shadow(radius: 4)
                                    Spacer()
                                }
                                .padding()
                            }
                        )
                        .padding(.bottom, 10)
                }

                ForEach(entry.blocks, id: \.id) { block in
                    switch block {
                    case .text(_, let content):
                        Text(content)
                            .font(.body)
                            .padding(.horizontal)
                    case .media(_, let id, let isVideo):
                        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject {
                            if isVideo {
                                VideoPlayerView(asset: asset)
                                    .frame(height: 250)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            } else {
                                AssetThumbnailView(asset: asset)
                                    .frame(height: 250)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }

                Spacer(minLength: 60)
            }
            .padding(.top)
        }
    }

    private func firstAsset(for entry: JournalEntry) -> PHAsset? {
        for block in entry.blocks {
            if case .media(_, let id, _) = block {
                return PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject
            }
        }
        return nil
    }
}
