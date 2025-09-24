
import PhotosUI
import SwiftUI
import Photos

struct NFCHomeView: View {
    var cityGroupedMedia: [String: [String: [MediaItem]]]

    var locationCount: Int {
        cityGroupedMedia.count
    }

    var recentMedia: [MediaItem] {
        cityGroupedMedia.values
            .flatMap { $0.values.flatMap { $0 } }
            .sorted(by: { $0.asset.creationDate ?? Date.distantPast > $1.asset.creationDate ?? Date.distantPast })
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Travel Journal")
                        .font(.title)
                        .bold()

                    Text("Scan NFC tags to explore your travel memories")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                Image("journal_header2")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0.4)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Travel Adventures")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Scan NFC tags to explore your travel memories")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        , alignment: .bottomLeading
                    )
                    .cornerRadius(20)
                    .padding(.horizontal)

                HStack(spacing: 16) {
                    StatCard(title: "Locations", value: "\(locationCount)", icon: "mappin.circle")
                    StatCard(title: "Media", value: "\(recentMedia.count)", icon: "camera")
                    StatCard(title: "Journals", value: "0", icon: "book")
                }
                .padding(.horizontal)

                // Recent Locations
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent Locations").font(.title3).bold()
                        Spacer()
                        Text("See All").foregroundColor(.green)
                    }

                    if locationCount > 0 {
                        ForEach(cityGroupedMedia.keys.sorted().prefix(3), id: \.self) { region in
                            if let firstCity = cityGroupedMedia[region]?.keys.first {
                                LocationCard(region: region, city: firstCity)
                            }
                        }
                    } else {
                        Text("No recent locations").foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                // Recent Media
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent Media").font(.title3).bold()
                        Spacer()
                        Text("See All").foregroundColor(.green)
                    }

                    if recentMedia.isEmpty {
                        Text("No recent media").foregroundColor(.gray)
                    } else {
                        ForEach(recentMedia, id: \.id) { media in
                            MediaCard(item: media)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
    }
}

// MARK: - Components

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.green)
            Text(value)
                .font(.title2)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct LocationCard: View {
    let region: String
    let city: String

    var body: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
                .foregroundColor(.green)
                .font(.title2)
            VStack(alignment: .leading) {
                Text(region).font(.headline)
                Text(city).font(.subheadline).foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

struct MediaCard: View {
    let item: MediaItem

    var body: some View {
        HStack(spacing: 12) {
            PhotoThumbnailView(item: item)
                .frame(width: 60, height: 60)
                .cornerRadius(8)

            VStack(alignment: .leading) {
                Text(item.city).font(.headline)
                if let date = item.asset.creationDate {
                    Text(date.formatted(date: .abbreviated, time: .omitted)).font(.subheadline).foregroundColor(.gray)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
    }
}
