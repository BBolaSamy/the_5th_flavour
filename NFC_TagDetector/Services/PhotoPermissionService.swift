import Foundation
import Photos
import CoreLocation
import Combine

@MainActor
class PhotoPermissionService: ObservableObject {
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isRequestingPermission = false
    
    init() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func requestPermission() async -> Bool {
        isRequestingPermission = true
        defer { isRequestingPermission = false }
        
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        authorizationStatus = status
        
        return status == .authorized || status == .limited
    }
    
    var hasPermission: Bool {
        authorizationStatus == .authorized || authorizationStatus == .limited
    }
    
    var canRequestPermission: Bool {
        authorizationStatus == .notDetermined
    }
}

@MainActor
class LocationBasedMediaService: ObservableObject {
    @Published var mediaItems: [MediaItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let photoPermissionService = PhotoPermissionService()
    
    func fetchMediaNearLocation(
        coordinate: CLLocationCoordinate2D,
        radiusKm: Double = 50.0
    ) async {
        guard photoPermissionService.hasPermission else {
            errorMessage = "Photo library access is required"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let media = try await fetchPhotosInRadius(
                center: coordinate,
                radiusKm: radiusKm
            )
            
            mediaItems = media
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func fetchPhotosInRadius(
        center: CLLocationCoordinate2D,
        radiusKm: Double
    ) async throws -> [MediaItem] {
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1000 // Limit for performance
        
        let assets = PHAsset.fetchAssets(with: fetchOptions)
        var nearbyMedia: [MediaItem] = []
        
        assets.enumerateObjects { asset, _, _ in
            guard let location = asset.location else { return }
            
            let distance = centerLocation.distance(from: location) / 1000.0 // Convert to km
            
            if distance <= radiusKm {
                let mediaItem = MediaItem(
                    asset: asset,
                    region: "Unknown", // Will be determined by geocoding
                    city: "Unknown", // Will be determined by geocoding
                    location: location
                )
                nearbyMedia.append(mediaItem)
            }
        }
        
        return nearbyMedia
    }
    
    func requestPhotoPermission() async -> Bool {
        return await photoPermissionService.requestPermission()
    }
    
    var hasPhotoPermission: Bool {
        photoPermissionService.hasPermission
    }
}

// MARK: - Media Item Extensions

extension MediaItem {
    var distanceFromLocation: Double? {
        guard let mediaLocation = location else { return nil }
        // This would be calculated based on a reference location
        return nil
    }
    
    var formattedDistance: String? {
        guard let distance = distanceFromLocation else { return nil }
        
        if distance < 1.0 {
            return String(format: "%.0f m", distance * 1000)
        } else {
            return String(format: "%.1f km", distance)
        }
    }
}
