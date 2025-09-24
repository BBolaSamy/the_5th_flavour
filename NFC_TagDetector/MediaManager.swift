

import Foundation
import Foundation
import Combine
import CoreLocation

class MediaManager: ObservableObject {
    @Published var cityGroupedMedia: [String: [String: [MediaItem]]] = [:]

    func updateMedia(region: String, city: String, media: [MediaItem]) {
        if cityGroupedMedia[region] == nil {
            cityGroupedMedia[region] = [:]
        }
        cityGroupedMedia[region]?[city] = media
    }
}
