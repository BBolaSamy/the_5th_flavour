//
//  MapPlaceholderView.swift
//  NFC_TagDetector
//
//  Created by George Saleip on 26.05.25.
//

import Foundation
import SwiftUI

struct MapPlaceholderView: View {
    var body: some View {
        VStack {
            Text("Travel Map")
                .font(.title)
                .padding()

            Image(systemName: "map")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)

            Text("This is a placeholder for the map screen.")
                .foregroundColor(.gray)
        }
    }
}
