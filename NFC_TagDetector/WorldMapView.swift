import Foundation
import SwiftUI
import MapKit

struct WorldMapView: View {
    let cityGroupedMedia: [String: [String: [MediaItem]]]
    @EnvironmentObject var journalStore: JournalStore
    @State private var suggestedImageURL: URL? = nil

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 100.0, longitudeDelta: 100.0)
    )

    @State private var showLazioDot = false
    @State private var selectedJournal: JournalEntry? = nil
    @State private var showJournalDetail = false

    struct SuggestionWrapper: Identifiable, Codable {
        let id = UUID()
        let city: String
        let country: String
        let description: String
        let imageURL: URL?

        var text: String {
            "\(city), \(country): \(description)"
        }
    }

    @State private var suggestedTrip: SuggestionWrapper? = nil
    @State private var wishlist: [SuggestionWrapper] = []

    var mediaLocations: [MediaLocation] {
        cityGroupedMedia.flatMap { $0.value.flatMap { $0.value.compactMap { $0.asset.location.map { MediaLocation(title: $0.description, coordinate: $0.coordinate) } } } }
    }

    var journalPins: [JournalPin] {
        journalStore.entries.compactMap { entry in
            entry.gpsCoordinate.map { JournalPin(entry: entry, coordinate: $0) }
        }
    }

    var lazioLocation: MediaLocation {
        MediaLocation(title: "Lazio", coordinate: CLLocationCoordinate2D(latitude: 41.89, longitude: 12.5))
    }
    
    var body: some View {
        ZStack {
            Color.uberBackground.ignoresSafeArea()

            Map(coordinateRegion: $region, annotationItems: mediaLocations + [lazioLocation]) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(.white, lineWidth: 1.5))
                        .shadow(radius: 2)
                }
            }
            .mapStyle(.standard(elevation: .realistic))

            Map(coordinateRegion: $region, annotationItems: journalPins) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
                    Button {
                        centerOnLocation(pin.coordinate)
                        selectedJournal = pin.entry
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showJournalDetail = true
                        }
                    } label: {
                        Image(systemName: "book.fill")
                            .foregroundColor(.uberAccent)
                            .background(Circle().fill(Color.white))
                            .font(.system(size: 22))
                            .shadow(radius: 3)
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))

            VStack {
                Spacer()
                
                Button("\u{1F30D} AI: Suggest My Next Trip") {
                    let centerCoord = region.center
                    let closestRegion = journalPins.min(by: {
                        distance(from: $0.coordinate, to: centerCoord) < distance(from: $1.coordinate, to: centerCoord)
                    })?.entry.region ?? ""

                    let journalText = journalStore.journalText(for: closestRegion)

                    GPTService().suggestNextDestination(from: journalText, currentRegion: closestRegion) { resultText in
                        print("\u{1F9E0} GPT raw response:\n\(resultText ?? "nil")")

                        guard let resultText = resultText, !resultText.isEmpty else {
                            suggestedTrip = SuggestionWrapper(
                                city: "\u{26A0}\u{FE0F}",
                                country: "",
                                description: "Couldn't parse a valid suggestion. Try again.",
                                imageURL: nil
                            )
                            return
                        }

                        let extractedCity = resultText.components(separatedBy: ",").first ?? ""

                        UnsplashImageFetcher.fetchImageURL(for: extractedCity) { imageURL in
                            DispatchQueue.main.async {
                                suggestedTrip = SuggestionWrapper(
                                    city: extractedCity,
                                    country: "",
                                    description: resultText,
                                    imageURL: imageURL
                                )
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showJournalDetail) {
            if let entry = selectedJournal {
                JournalDetailView(entry: entry)
            }
        }
        .sheet(item: $suggestedTrip) { suggestion in
            VStack(spacing: 20) {
                if let url = suggestion.imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 240)
                                .clipped()
                                .cornerRadius(12)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }.padding(.top)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("\u{1F30D} \(suggestion.city), \(suggestion.country)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.uberTextPrimary)

                    Text("\u{1F4DD} \(suggestion.description)")
                        .font(.body)
                        .foregroundColor(.uberTextSecondary)
                }
                .padding(.horizontal)

                Spacer()

                Button(action: {
                    wishlist.append(suggestion)
                }) {
                    Text("\u{1F4BE} Save to Wishlist")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.uberAccent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                Button("Close") {
                    suggestedTrip = nil
                }
                .padding(.bottom, 20)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .mediaUpdatedForRegion)) { notification in
            if let regionName = notification.object as? String {
                if regionName == "Lazio" {
                    withAnimation {
                        showLazioDot = true
                    }
                }
                if let journal = journalStore.entries.last,
                   let newCoord = journal.gpsCoordinate {
                    centerOnLocation(newCoord)
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private func centerOnLocation(_ coordinate: CLLocationCoordinate2D) {
        withAnimation {
            region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 4.0, longitudeDelta: 4.0))
        }
    }

    private func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let loc2 = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return loc1.distance(from: loc2)
    }
    
    private func extractCity(from text: String) -> String {
        // Try to extract first city from the GPT response
        let firstLine = text.components(separatedBy: .newlines).first ?? text
        let components = firstLine.components(separatedBy: ",")
        return components.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown"
    }
}

struct MediaLocation: Identifiable {
    let id = UUID()
    let title: String
    let coordinate: CLLocationCoordinate2D
}

struct JournalPin: Identifiable {
    let id = UUID()
    let entry: JournalEntry
    let coordinate: CLLocationCoordinate2D
}
