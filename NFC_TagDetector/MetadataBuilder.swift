

import Foundation
import Photos
import CoreLocation

struct MetadataBuilder {
    static func buildSummary(from item: MediaItem, completion: @escaping (MediaMetadataSummary?) -> Void) {
        let asset = item.asset

        // Location
        let location = asset.location?.description ?? "an unknown place"

        // Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = asset.creationDate.map { dateFormatter.string(from: $0) } ?? "an unknown time"

        // People (use placeholder for now, you can integrate face recognition later)
        let people = "a friend and me"

        // Scene (you can extend this with AI image analysis later)
        let scene = item.isVideo ? "recording a video" : "taking a photo"

        // Mood (placeholder — can be AI-generated from facial expression later)
        let mood = "joyful"

        let summary = MediaMetadataSummary(
            location: location,
            date: date,
            people: people,
            scene: scene,
            mood: mood
        )

        completion(summary)
    }
}
