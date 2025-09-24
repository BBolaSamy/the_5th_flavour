//
//  TravelJournalView.swift
//  NFC_TagDetector
//
//  Created by George Saleip on 26.05.25.
//

import Foundation
import SwiftUI

struct TravelJournalView: View {
    var body: some View {
        VStack {
            Text("Travel Journal")
                .font(.title)
                .padding()

            Image(systemName: "book.closed")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)

            Text("This is a placeholder for the Journal screen.")
                .foregroundColor(.gray)
        }
    }
}
