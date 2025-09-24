import Foundation
import Photos
import CoreLocation
import UIKit

struct MediaItem: Identifiable, Hashable, Codable {
    let id: UUID
    let assetIdentifier: String
    let region: String
    let city: String
    var latitude: Double?
    var longitude: Double?
    var detectedObjects: [String] = []
    

    // Computed properties (excluded from Codable)
    var location: CLLocation? {
        if let lat = latitude, let lon = longitude {
            return CLLocation(latitude: lat, longitude: lon)
        }
        return nil
    }

    var asset: PHAsset {
        PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject ?? PHAsset()
    }

    var isImage: Bool {
        asset.mediaType == .image
    }

    var isVideo: Bool {
        asset.mediaType == .video
    }

    var duration: TimeInterval {
        asset.duration
    }

    func requestThumbnail(size: CGSize = CGSize(width: 100, height: 100), completion: @escaping (UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact

        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { image, _ in
            completion(image)
        }
    }

    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        lhs.assetIdentifier == rhs.assetIdentifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(assetIdentifier)
    }

    init(asset: PHAsset, region: String, city: String, location: CLLocation?) {
        self.id = UUID()
        self.assetIdentifier = asset.localIdentifier
        self.region = region
        self.city = city
        self.latitude = location?.coordinate.latitude
        self.longitude = location?.coordinate.longitude
    }
}
