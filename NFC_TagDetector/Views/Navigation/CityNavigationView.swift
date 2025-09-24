import SwiftUI
import CoreLocation

struct CityNavigationView: View {
    @StateObject private var roadTripService = RoadTripService()
    @State private var selectedCityIndex = 0
    @State private var selectedFilter: MediaFilter = .all
    @State private var showingRoadTripSetup = false
    
    let cities: [TripCity]
    
    enum MediaFilter: String, CaseIterable {
        case all = "All"
        case photos = "Photos"
        case videos = "Videos"
        case journals = "Journals"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .photos: return "photo"
            case .videos: return "video"
            case .journals: return "book"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // City Tabs
            if cities.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(cities.enumerated()), id: \.element.id) { index, city in
                            CityTab(
                                city: city,
                                isSelected: selectedCityIndex == index
                            ) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedCityIndex = index
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.05))
            }
            
            // Filter Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(MediaFilter.allCases, id: \.self) { filter in
                        FilterTab(
                            filter: filter,
                            isSelected: selectedFilter == filter
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFilter = filter
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
            .background(Color.white)
            
            // Content
            if cities.isEmpty {
                EmptyCitiesView {
                    showingRoadTripSetup = true
                }
            } else {
                TabView(selection: $selectedCityIndex) {
                    ForEach(Array(cities.enumerated()), id: \.element.id) { index, city in
                        CityContentView(
                            city: city,
                            filter: selectedFilter
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: selectedCityIndex)
            }
        }
        .navigationTitle(roadTripService.currentTrip?.name ?? "Cities")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingRoadTripSetup = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingRoadTripSetup) {
            RoadTripSetupView()
        }
    }
}

struct CityTab: View {
    let city: TripCity
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(city.name)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(city.visitDate, style: .date)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Image(systemName: "photo")
                            .font(.caption2)
                        Text("\(city.mediaCount)")
                            .font(.caption2)
                    }
                    
                    HStack(spacing: 2) {
                        Image(systemName: "book")
                            .font(.caption2)
                        Text("\(city.journalCount)")
                            .font(.caption2)
                    }
                }
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FilterTab: View {
    let filter: CityNavigationView.MediaFilter
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.caption)
                Text(filter.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.green : Color.gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CityContentView: View {
    let city: TripCity
    let filter: CityNavigationView.MediaFilter
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // City Header
                VStack(spacing: 8) {
                    Text(city.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(city.visitDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Content based on filter
                switch filter {
                case .all:
                    AllContentView(city: city)
                case .photos:
                    PhotosContentView(city: city)
                case .videos:
                    VideosContentView(city: city)
                case .journals:
                    JournalsContentView(city: city)
                }
            }
        }
    }
}

struct AllContentView: View {
    let city: TripCity
    
    var body: some View {
        VStack(spacing: 16) {
            // Recent Photos
            if !city.mediaItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Photos")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(city.mediaItems.prefix(10)) { mediaItem in
                                MediaThumbnailView(
                                    mediaItem: mediaItem,
                                    isSelected: false,
                                    onToggleSelection: {},
                                    onTap: {}
                                )
                                .frame(width: 80, height: 80)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // Journals
            if city.journalCount > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Journals")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // Journal cards would go here
                    Text("\(city.journalCount) journal entries")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
            }
        }
    }
}

struct PhotosContentView: View {
    let city: TripCity
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 2) {
            ForEach(city.mediaItems.filter { $0.asset.mediaType == .image }) { mediaItem in
                MediaThumbnailView(
                    mediaItem: mediaItem,
                    isSelected: false,
                    onToggleSelection: {},
                    onTap: {}
                )
            }
        }
        .padding(.horizontal)
    }
}

struct VideosContentView: View {
    let city: TripCity
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 2) {
            ForEach(city.mediaItems.filter { $0.asset.mediaType == .video }) { mediaItem in
                MediaThumbnailView(
                    mediaItem: mediaItem,
                    isSelected: false,
                    onToggleSelection: {},
                    onTap: {}
                )
            }
        }
        .padding(.horizontal)
    }
}

struct JournalsContentView: View {
    let city: TripCity
    
    var body: some View {
        VStack(spacing: 16) {
            if city.journalCount > 0 {
                ForEach(0..<city.journalCount, id: \.self) { _ in
                    JournalCard(city: city)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "book")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No journals yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Create your first journal entry for \(city.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .padding(.horizontal)
    }
}

struct JournalCard: View {
    let city: TripCity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Memories from \(city.name)")
                .font(.headline)
            
            Text("A beautiful day exploring the city...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Text(city.visitDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct EmptyCitiesView: View {
    let onCreateTrip: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "car")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            Text("No Cities Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Start a road trip to organize your travel memories by city")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Start Road Trip") {
                onCreateTrip()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationView {
        CityNavigationView(cities: [
            TripCity(name: "San Francisco", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), visitDate: Date()),
            TripCity(name: "Los Angeles", coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), visitDate: Date())
        ])
    }
}
