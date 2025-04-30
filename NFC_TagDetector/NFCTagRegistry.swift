//
//  NFCTagRegistry.swift
//  NFC_TagDetector
//
//  Created by George Saleip on 22.04.25.
//

import Foundation

struct NFCTagRegistry {
    static let tagToRegion: [String: String] = [
        "04A224B8C12980": "Lazio", // Example NFC tag ID → Region
        "04A224B8C12981": "Sicilia",
        // Add more as needed
    ]
}
