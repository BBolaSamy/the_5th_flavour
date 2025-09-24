//
//  JournalEditorView.swift
//  NFC_TagDetector
//
//  Created by George Saleip on 28.05.25.
//

import Foundation
import SwiftUI
import Photos

struct JournalEditorView: View {
    let mediaItems: [MediaItem]
    let region: String

    @Environment(\.dismiss) var dismiss
    @State private var selectedItems: [MediaItem] = []
    @State private var textBlocks: [String] = []
    @State private var editingText: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(selectedItems.indices, id: \.self) { index in
                        let item = selectedItems[index]
                        PhotoThumbnailView(item: item)

                        // Add optional text block between media
                        if textBlocks.indices.contains(index) {
                            TextEditor(text: Binding(
                                get: { textBlocks[index] },
                                set: { textBlocks[index] = $0 }
                            ))
                            .frame(height: 100)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }

                        Button("Add Text Here") {
                            textBlocks.insert("", at: index)
                        }
                        .font(.caption)
                    }

                    if selectedItems.isEmpty {
                        Text("Select media to start creating your entry.")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
            .navigationTitle("New Journal Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                        dismiss()
                    }
                    .disabled(selectedItems.isEmpty)
                }
            }
        }
        .onAppear {
            selectedItems = mediaItems // Pre-fill with all items, or implement selection UI if you prefer
            textBlocks = Array(repeating: "", count: mediaItems.count)
        }
    }

    func saveEntry() {
        // Here you’ll store the journal entry — could be CoreData, file, or cloud
        print("Saving journal with \(selectedItems.count) items and \(textBlocks.count) texts.")
    }
}
