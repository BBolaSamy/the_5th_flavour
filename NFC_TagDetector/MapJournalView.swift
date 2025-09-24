import SwiftUI
import MapKit
import Photos

struct MapJournalView: View {
    @EnvironmentObject var journalStore: JournalStore

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
        span: MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20)
    )

    @State private var selectedEntryID: UUID?
    @State private var tappedEntry: JournalEntry?

    var body: some View {
        VStack(spacing: 0) {
            Map(coordinateRegion: $region, annotationItems: pinLocations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    Circle()
                        .fill(location.id == selectedEntryID ? .red : .blue)
                        .frame(width: 12, height: 12)
                        .onTapGesture {
                            selectedEntryID = location.id
                            if let entry = journalStore.entries.first(where: { $0.id == location.id }) {
                                tappedEntry = entry
                                if let loc = getLocation(for: entry) {
                                    withAnimation {
                                        region.center = loc.coordinate
                                    }
                                }
                            }
                        }
                }
            }
            .frame(height: 300)

            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(journalStore.entries) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                if let asset = firstAsset(for: entry) {
                                    AssetThumbnailView(asset: asset)
                                        .frame(width: 120, height: 80)
                                        .cornerRadius(10)
                                }

                                Text(entry.title.isEmpty ? "Untitled Trip" : entry.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text(entry.region)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(entry.id == selectedEntryID ? Color.green.opacity(0.2) : Color(.systemBackground))
                            .cornerRadius(12)
                            .id(entry.id)
                            .onTapGesture {
                                selectedEntryID = entry.id
                                tappedEntry = entry
                                if let location = getLocation(for: entry) {
                                    withAnimation {
                                        region.center = location.coordinate
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                .onChange(of: selectedEntryID) { newID in
                    if let id = newID {
                        withAnimation {
                            scrollProxy.scrollTo(id, anchor: .center)
                        }
                    }
                }
            }
        }
        .sheet(item: $tappedEntry) { entry in
            JournalDetailView(entry: entry)
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

    private func getLocation(for entry: JournalEntry) -> CLLocation? {
        for block in entry.blocks {
            if case .media(_, let id, _) = block {
                return PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject?.location
            }
        }
        return nil
    }

    private var pinLocations: [MapPin] {
        journalStore.entries.compactMap { entry in
            if let location = getLocation(for: entry) {
                return MapPin(id: entry.id, coordinate: location.coordinate)
            }
            return nil
        }
    }
}

struct MapPin: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
}
