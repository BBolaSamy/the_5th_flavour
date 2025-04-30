//
//  MediaItem.swift
//  NFC_TagDetector
//
//  Created by George Saleip on 22.04.25.
//

import Foundation
import Photos
import PhotosUI
import SwiftUI

struct MediaItem: Identifiable, Hashable {
    let id = UUID()
    let asset: PHAsset
    let region: String
    var location: CLLocation?

    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        return lhs.asset.localIdentifier == rhs.asset.localIdentifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.localIdentifier)
    }
}

