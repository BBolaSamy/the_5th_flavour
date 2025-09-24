

import Foundation
import MapKit // ✅ Add this

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    var title: String
    var region: String
    var createdAt: Date
    var blocks: [JournalBlock]

    init(title: String = "", region: String, blocks: [JournalBlock]) {
        self.id = UUID()
        self.title = title
        self.region = region
        self.createdAt = Date()
        self.blocks = blocks
    }

    var gpsCoordinate: CLLocationCoordinate2D? {
        switch region {
        case "Lazio":
            return CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5)
        case "Braunschweig":
            return CLLocationCoordinate2D(latitude: 52.3, longitude: 10.5)
        default:
            return nil
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
}
