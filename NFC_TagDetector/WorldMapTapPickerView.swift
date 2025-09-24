import SwiftUI
import MapKit

struct WorldMapTapPickerView: View {
    var onLocationPicked: (CLLocationCoordinate2D) -> Void
    @Environment(\.dismiss) var dismiss

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
    )

    var body: some View {
        Map(coordinateRegion: $region, interactionModes: .all)
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        // TEMP: Use region center as tapped coordinate
                        let coordinate = region.center
                        onLocationPicked(coordinate)
                        dismiss()
                    }
            )
            .overlay(
                VStack {
                    Text("🌍 Tap anywhere to choose a location")
                        .font(.headline)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.top, 40)
                    Spacer()
                }
            )
    }
}
