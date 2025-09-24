import Foundation
import CoreLocation

struct RoadTrip: Identifiable, Codable {
    let id: String
    let name: String
    let startDate: Date
    let endDate: Date
    let cities: [TripCity]
    let route: [CLLocationCoordinate2D]
    let createdAt: Date
    
    init(name: String, startDate: Date, endDate: Date, cities: [TripCity] = []) {
        self.id = UUID().uuidString
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.cities = cities
        self.route = cities.map { $0.coordinate }
        self.createdAt = Date()
    }
    
    var duration: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    var totalPhotos: Int {
        cities.reduce(0) { $0 + $1.mediaCount }
    }
    
    var totalJournals: Int {
        cities.reduce(0) { $0 + $1.journalCount }
    }
}

struct TripCity: Identifiable, Codable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let visitDate: Date
    let mediaCount: Int
    let journalCount: Int
    let mediaItems: [MediaItem]
    
    init(name: String, coordinate: CLLocationCoordinate2D, visitDate: Date, mediaItems: [MediaItem] = []) {
        self.id = UUID().uuidString
        self.name = name
        self.coordinate = coordinate
        self.visitDate = visitDate
        self.mediaItems = mediaItems
        self.mediaCount = mediaItems.count
        self.journalCount = 0 // This would be calculated from journals
    }
}

// MARK: - CLLocationCoordinate2D Codable Support

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
}

// MARK: - Road Trip Service

@MainActor
class RoadTripService: ObservableObject {
    @Published var currentTrip: RoadTrip?
    @Published var allTrips: [RoadTrip] = []
    @Published var isLoading = false
    
    private let fileName = "road_trips.json"
    
    init() {
        loadTrips()
    }
    
    func createRoadTrip(name: String, startDate: Date, endDate: Date) {
        let trip = RoadTrip(name: name, startDate: startDate, endDate: endDate)
        currentTrip = trip
        allTrips.append(trip)
        saveTrips()
    }
    
    func addCityToTrip(_ city: TripCity) {
        guard var trip = currentTrip else { return }
        
        var updatedCities = trip.cities
        updatedCities.append(city)
        
        let updatedTrip = RoadTrip(
            name: trip.name,
            startDate: trip.startDate,
            endDate: trip.endDate,
            cities: updatedCities
        )
        
        currentTrip = updatedTrip
        
        // Update in all trips
        if let index = allTrips.firstIndex(where: { $0.id == trip.id }) {
            allTrips[index] = updatedTrip
        }
        
        saveTrips()
    }
    
    func fetchMediaForDateRange(startDate: Date, endDate: Date) async -> [MediaItem] {
        // This would fetch media from PhotoKit within the date range
        // and reverse geocode to group by cities
        return []
    }
    
    func endCurrentTrip() {
        currentTrip = nil
    }
    
    // MARK: - Persistence
    
    private func saveTrips() {
        do {
            let data = try JSONEncoder().encode(allTrips)
            let url = getFileURL()
            try data.write(to: url, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Failed to save road trips: \(error)")
        }
    }
    
    private func loadTrips() {
        do {
            let url = getFileURL()
            let data = try Data(contentsOf: url)
            allTrips = try JSONDecoder().decode([RoadTrip].self, from: data)
        } catch {
            print("Failed to load road trips: \(error)")
            allTrips = []
        }
    }
    
    private func getFileURL() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(fileName)
    }
}
