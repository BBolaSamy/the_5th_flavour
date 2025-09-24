
import Foundation
import SwiftUI

struct JournalListView: View {
    @EnvironmentObject var journalStore: JournalStore

    var body: some View {
        NavigationView {
            List {
                ForEach(journalStore.entries.sorted(by: { $0.createdAt > $1.createdAt })) { entry in
                    NavigationLink(destination: JournalDetailView(entry: entry)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.title)
                                .font(.headline)
                                .foregroundColor(.uberTextPrimary)

                            Text(entry.region)
                                .font(.subheadline)
                                .foregroundColor(.uberTextSecondary)

                            Text(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.uberTextSecondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .scrollContentBackground(.hidden) // ✅ Ensures background color is visible
            .background(Color.uberBackground)
            .navigationTitle("Your Journals")
            .foregroundColor(.uberTextPrimary)
        }
    }
}
