//
//  CityListView.swift
//  NFC_TagDetector
//
//  Created by George Saleip on 05.05.25.
//

import Foundation
import SwiftUI

struct CityListView: View {
    let cities: [String]
    let onSelect: (String) -> Void
    let onClose: () -> Void

    var body: some View {
        NavigationView {
            List(cities, id: \.self) { city in
                Button(action: { onSelect(city) }) {
                    Text(city)
                }
            }
            .navigationTitle("Select a City")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onClose)
                }
            }
        }
    }
}
