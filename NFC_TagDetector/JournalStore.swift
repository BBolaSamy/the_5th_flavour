

import Foundation
import SwiftUI

class JournalStore: ObservableObject {
    @Published var entries: [JournalEntry] = [] {
        didSet {
            saveToDisk()
        }
    }

    private let fileName = "saved_journals.json"

    init() {
        loadFromDisk()
    }

    func add(_ entry: JournalEntry) {
        entries.append(entry)
    }

    func remove(at index: Int) {
        guard entries.indices.contains(index) else { return }
        entries.remove(at: index)
    }

    func clearAll() {
        entries.removeAll()
    }

    // MARK: - Persistence

    private func getFileURL() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(fileName)
    }

    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: getFileURL(), options: [.atomicWrite, .completeFileProtection])
            print("✅ Journals saved to disk")
        } catch {
            print("❌ Failed to save journals: \(error.localizedDescription)")
        }
    }

    func journalText(for region: String) -> String {
        let matchingEntries = entries.filter { $0.region == region }
        
        let textBlocks = matchingEntries.flatMap { entry in
            entry.blocks.compactMap { block in
                if case let .text(_, content) = block {
                    return content
                }
                return nil
            }
        }
        
        return textBlocks.joined(separator: "\n\n")
    }

    
    private func loadFromDisk() {
        let url = getFileURL()
        do {
            let data = try Data(contentsOf: url)
            entries = try JSONDecoder().decode([JournalEntry].self, from: data)
            print("📥 Loaded \(entries.count) journal entries from disk")
        } catch {
            print("⚠️ No saved journals found or failed to load: \(error.localizedDescription)")
            entries = []
        }
    }
}
