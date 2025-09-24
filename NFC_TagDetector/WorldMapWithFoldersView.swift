import SwiftUI
import MapKit

struct MappedEntry: Identifiable {
    let id: UUID
    let entry: JournalEntry
    let coord: CLLocationCoordinate2D
    let thumbnail: UIImage?
}

struct MapViewWithPins: View {
    @EnvironmentObject var journalStore: JournalStore
    @Binding var selectedRegion: String?

    // Automatically collects coordinates from entries
    var regionCoordinates: [String: CLLocationCoordinate2D] {
        journalStore.entries.reduce(into: [:]) { dict, entry in
            if let coord = entry.gpsCoordinate {
                dict[entry.region] = coord
            }
        }
    }

    var entriesWithCoordinates: [MappedEntry] {
        journalStore.entries.compactMap { entry in
            guard let coord = regionCoordinates[entry.region] else { return nil }

            var thumbnail: UIImage? = nil
            for block in entry.blocks {
                if case let .media(_, identifier, isVideo) = block, !isVideo {
                    if FileManager.default.fileExists(atPath: identifier) {
                        thumbnail = UIImage(contentsOfFile: identifier)
                    }
                    break
                }
            }

            return MappedEntry(id: entry.id, entry: entry, coord: coord, thumbnail: thumbnail)
        }
    }

    var body: some View {
        Map(
            coordinateRegion: .constant(
                MKCoordinateRegion(
                    center: regionCoordinates[selectedRegion ?? ""] ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
                    span: MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20)
                )
            ),
            annotationItems: entriesWithCoordinates
        ) { item in
            MapMarker(coordinate: item.coord, tint: .green)
        }
    }
}

struct FolderCard: View {
    var entry: JournalEntry
    var thumbnail: UIImage?
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        VStack {
            if let thumb = thumbnail {
                Image(uiImage: thumb)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 100)
            }
            Text(entry.title.isEmpty ? "Untitled Entry" : entry.title)
                .font(.caption)
                .padding(.top, 4)
        }
        .background(isSelected ? Color.green : Color.gray.opacity(0.3))
        .cornerRadius(10)
        .onTapGesture { onTap() }
    }
}

struct WorldMapWithFoldersView: View {
    @EnvironmentObject var journalStore: JournalStore
    @State private var selectedRegion: String? = nil
    @State private var mapCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5)

    var body: some View {
        VStack(spacing: 0) {
            MapViewWithPins(selectedRegion: $selectedRegion)
                .frame(maxHeight: .infinity)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    let filteredEntries = journalStore.entries.filter { !$0.blocks.isEmpty }
                    ForEach(filteredEntries, id: \ .id) { entry in
                        let thumb: UIImage? = {
                            for block in entry.blocks {
                                if case let .media(_, identifier, isVideo) = block, !isVideo {
                                    if FileManager.default.fileExists(atPath: identifier) {
                                        return UIImage(contentsOfFile: identifier)
                                    }
                                }
                            }
                            return nil
                        }()

                        FolderCard(
                            entry: entry,
                            thumbnail: thumb,
                            isSelected: selectedRegion == entry.region
                        ) {
                            selectedRegion = entry.region
                            if let newCoord = entry.gpsCoordinate {
                                mapCenter = newCoord
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 140)
            .background(Color.white)
        }
    }
}
