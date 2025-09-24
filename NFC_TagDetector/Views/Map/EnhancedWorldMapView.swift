import SwiftUI
import MapKit
import CoreLocation

struct EnhancedWorldMapView: View {
    @EnvironmentObject var journalStore: JournalStore
    @EnvironmentObject var roadTripService: RoadTripService
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 100.0, longitudeDelta: 100.0)
    )
    @State private var selectedCity: CityPin?
    @State private var showingCityDetail = false
    @State private var mapType: MKMapType = .standard
    @State private var showingFilters = false
    @State private var selectedFilter: MapFilter = .all
    
    enum MapFilter: String, CaseIterable {
        case all = "All"
        case withPhotos = "With Photos"
        case withJournals = "With Journals"
        case roadTrips = "Road Trips"
        
        var icon: String {
            switch self {
            case .all: return "globe"
            case .withPhotos: return "photo"
            case .withJournals: return "book"
            case .roadTrips: return "car"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Map
            Map(coordinateRegion: $region, annotationItems: filteredCityPins) { cityPin in
                MapAnnotation(coordinate: cityPin.coordinate) {
                    CityMapPin(
                        cityPin: cityPin,
                        isSelected: selectedCity?.id == cityPin.id
                    ) {
                        selectedCity = cityPin
                        showingCityDetail = true
                    }
                }
            }
            .mapStyle(mapType == .standard ? .standard : .hybrid)
            .ignoresSafeArea()
            
            // Top Controls
            VStack {
                HStack {
                    // Map Type Toggle
                    Button(action: {
                        mapType = mapType == .standard ? .satellite : .standard
                    }) {
                        Image(systemName: mapType == .standard ? "globe" : "map")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Filter Button
                    Button(action: {
                        showingFilters = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
            }
            
            // Bottom City Thumbnails
            if !cityPins.isEmpty {
                VStack {
                    Spacer()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filteredCityPins) { cityPin in
                                CityThumbnailCard(
                                    cityPin: cityPin,
                                    isSelected: selectedCity?.id == cityPin.id
                                ) {
                                    selectedCity = cityPin
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        region.center = cityPin.coordinate
                                        region.span = MKCoordinateSpan(
                                            latitudeDelta: 2.0,
                                            longitudeDelta: 2.0
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 100) // Space for tab bar
                }
            }
        }
        .navigationTitle("World Map")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCityDetail) {
            if let cityPin = selectedCity {
                CityDetailView(cityPin: cityPin)
            }
        }
        .sheet(isPresented: $showingFilters) {
            MapFilterView(selectedFilter: $selectedFilter)
        }
        .onAppear {
            loadCityPins()
        }
    }
    
    private var cityPins: [CityPin] {
        var pins: [CityPin] = []
        
        // Add pins from journal entries
        for entry in journalStore.entries {
            if let coordinate = getCoordinateForRegion(entry.region) {
                let existingPin = pins.first { $0.coordinate.latitude == coordinate.latitude && $0.coordinate.longitude == coordinate.longitude }
                
                if let existingPin = existingPin {
                    // Update existing pin
                    if let index = pins.firstIndex(where: { $0.id == existingPin.id }) {
                        pins[index].journalCount += 1
                    }
                } else {
                    // Create new pin
                    let pin = CityPin(
                        name: entry.region,
                        coordinate: coordinate,
                        photoCount: 0,
                        journalCount: 1,
                        isRoadTrip: false
                    )
                    pins.append(pin)
                }
            }
        }
        
        // Add pins from road trips
        for trip in roadTripService.allTrips {
            for city in trip.cities {
                let existingPin = pins.first { $0.coordinate.latitude == city.coordinate.latitude && $0.coordinate.longitude == city.coordinate.longitude }
                
                if let existingPin = existingPin {
                    // Update existing pin
                    if let index = pins.firstIndex(where: { $0.id == existingPin.id }) {
                        pins[index].photoCount += city.mediaCount
                        pins[index].isRoadTrip = true
                    }
                } else {
                    // Create new pin
                    let pin = CityPin(
                        name: city.name,
                        coordinate: city.coordinate,
                        photoCount: city.mediaCount,
                        journalCount: city.journalCount,
                        isRoadTrip: true
                    )
                    pins.append(pin)
                }
            }
        }
        
        return pins
    }
    
    private var filteredCityPins: [CityPin] {
        switch selectedFilter {
        case .all:
            return cityPins
        case .withPhotos:
            return cityPins.filter { $0.photoCount > 0 }
        case .withJournals:
            return cityPins.filter { $0.journalCount > 0 }
        case .roadTrips:
            return cityPins.filter { $0.isRoadTrip }
        }
    }
    
    private func loadCityPins() {
        // Center map on first pin if available
        if let firstPin = cityPins.first {
            region.center = firstPin.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 20.0, longitudeDelta: 20.0)
        }
    }
    
    private func getCoordinateForRegion(_ regionName: String) -> CLLocationCoordinate2D? {
        // This would typically use a geocoding service
        // For now, return some mock coordinates
        let mockCoordinates: [String: CLLocationCoordinate2D] = [
            "San Francisco": CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            "New York": CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            "London": CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            "Paris": CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            "Tokyo": CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503)
        ]
        
        return mockCoordinates[regionName]
    }
}

struct CityPin: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    var photoCount: Int
    var journalCount: Int
    var isRoadTrip: Bool
}

struct CityMapPin: View {
    let cityPin: CityPin
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Pin background
                Circle()
                    .fill(isSelected ? Color.green : Color.blue)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                
                // Pin icon
                Image(systemName: cityPin.isRoadTrip ? "car.fill" : "location.fill")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .scaleEffect(isSelected ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CityThumbnailCard: View {
    let cityPin: CityPin
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // City name
                Text(cityPin.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Stats
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "photo")
                            .font(.caption)
                        Text("\(cityPin.photoCount)")
                            .font(.caption)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "book")
                            .font(.caption)
                        Text("\(cityPin.journalCount)")
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
                
                // Road trip indicator
                if cityPin.isRoadTrip {
                    HStack(spacing: 4) {
                        Image(systemName: "car.fill")
                            .font(.caption2)
                        Text("Road Trip")
                            .font(.caption2)
                    }
                    .foregroundColor(.green)
                }
            }
            .padding()
            .frame(width: 120, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green.opacity(0.1) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(radius: isSelected ? 4 : 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CityDetailView: View {
    let cityPin: CityPin
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // City Header
                VStack(spacing: 8) {
                    Text(cityPin.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(cityPin.photoCount) photos • \(cityPin.journalCount) journals")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Stats Cards
                HStack(spacing: 16) {
                    StatCard(
                        title: "Photos",
                        value: "\(cityPin.photoCount)",
                        icon: "photo.fill"
                    )
                    
                    StatCard(
                        title: "Journals",
                        value: "\(cityPin.journalCount)",
                        icon: "book.fill"
                    )
                }
                .padding(.horizontal)
                
                // Actions
                VStack(spacing: 12) {
                    Button("View Photos") {
                        // Navigate to photos
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    
                    Button("View Journals") {
                        // Navigate to journals
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    if cityPin.isRoadTrip {
                        Button("View Road Trip") {
                            // Navigate to road trip
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("City Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MapFilterView: View {
    @Binding var selectedFilter: EnhancedWorldMapView.MapFilter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(EnhancedWorldMapView.MapFilter.allCases, id: \.self) { filter in
                    HStack {
                        Image(systemName: filter.icon)
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        Text(filter.rawValue)
                        
                        Spacer()
                        
                        if selectedFilter == filter {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedFilter = filter
                        dismiss()
                    }
                }
            }
            .navigationTitle("Filter Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        EnhancedWorldMapView()
            .environmentObject(JournalStore())
            .environmentObject(RoadTripService())
    }
}
