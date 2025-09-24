import SwiftUI

struct CreateNewEntryView: View {
    let region: String
    let media: [MediaItem]

    @State private var selectedItems: [MediaItem] = []
    @State private var showEditor = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Section(header: Text("Select Media from \(region)")
                        .font(.headline)
                        .padding(.horizontal)) {

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 12) {
                            ForEach(media) { item in
                                PhotoThumbnailView(item: item) { tapped in
                                    toggleSelection(item: tapped)
                                }
                                .overlay(
                                    selectedItems.contains(item) ?
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .padding(6) : nil,
                                    alignment: .topTrailing
                                )
                            }
                        }
                        .padding()
                    }

                    if selectedItems.isEmpty {
                        Text("Select at least one photo or video to continue.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }

                Button("Next") {
                    showEditor = true
                }
                .disabled(selectedItems.isEmpty)
                .padding()
                .frame(maxWidth: .infinity)
                .background(selectedItems.isEmpty ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("New Journal Entry")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .sheet(isPresented: $showEditor) {
                JournalEditorView(
                    region: region,
                    initialMedia: selectedItems
                )
            }
        }
    }

    private func toggleSelection(item: MediaItem) {
        if let index = selectedItems.firstIndex(of: item) {
            selectedItems.remove(at: index)
        } else {
            selectedItems.append(item)
        }
    }
}
