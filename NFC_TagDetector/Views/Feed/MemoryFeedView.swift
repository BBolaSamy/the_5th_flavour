import SwiftUI

struct MemoryFeedView: View {
    @EnvironmentObject var journalStore: JournalStore
    @EnvironmentObject var roadTripService: RoadTripService
    @State private var selectedFilter: FeedFilter = .recent
    @State private var showingFilterSheet = false
    @State private var searchText = ""
    
    enum FeedFilter: String, CaseIterable {
        case recent = "Recent"
        case byTrip = "By Trip"
        case byCountry = "By Country"
        case favorites = "Favorites"
        
        var icon: String {
            switch self {
            case .recent: return "clock"
            case .byTrip: return "car"
            case .byCountry: return "globe"
            case .favorites: return "heart"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search memories...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button("Clear") {
                            searchText = ""
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Filter Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(FeedFilter.allCases, id: \.self) { filter in
                            MemoryFilterTab(
                                filter: filter,
                                isSelected: selectedFilter == filter
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedFilter = filter
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 8)
                
                // Content
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if filteredMemories.isEmpty {
                            EmptyFeedView(filter: selectedFilter)
                        } else {
                            ForEach(filteredMemories) { memory in
                                MemoryCard(memory: memory)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100) // Space for tab bar
                }
            }
            .navigationTitle("Memories")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilterSheet = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilterSheet) {
                FilterSheet(selectedFilter: $selectedFilter)
            }
        }
    }
    
    private var filteredMemories: [MemoryItem] {
        var memories: [MemoryItem] = []
        
        // Add journal entries as memories
        for entry in journalStore.entries {
            let memory = MemoryItem(
                id: entry.id.uuidString,
                title: entry.title,
                content: getContentFromBlocks(entry.blocks),
                location: entry.region,
                date: entry.createdAt,
                type: .journal,
                photoCount: 0,
                isFavorite: false
            )
            memories.append(memory)
        }
        
        // Add road trip memories
        for trip in roadTripService.allTrips {
            let memory = MemoryItem(
                id: trip.id,
                title: trip.name,
                content: "Road trip with \(trip.cities.count) cities",
                location: trip.cities.first?.name ?? "Unknown",
                date: trip.startDate,
                type: .roadTrip,
                photoCount: trip.totalPhotos,
                isFavorite: false
            )
            memories.append(memory)
        }
        
        // Apply filters
        var filtered = memories
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { memory in
                memory.title.localizedCaseInsensitiveContains(searchText) ||
                memory.content.localizedCaseInsensitiveContains(searchText) ||
                memory.location.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Type filter
        switch selectedFilter {
        case .recent:
            filtered = filtered.sorted { $0.date > $1.date }
        case .byTrip:
            filtered = filtered.filter { $0.type == .roadTrip }
        case .byCountry:
            // Group by country (simplified)
            filtered = filtered.sorted { $0.location < $1.location }
        case .favorites:
            filtered = filtered.filter { $0.isFavorite }
        }
        
        return filtered
    }
    
    private func getContentFromBlocks(_ blocks: [JournalBlock]) -> String {
        return blocks.compactMap { block in
            if case let .text(_, content) = block {
                return content
            }
            return nil
        }.joined(separator: " ")
    }
}

struct MemoryItem: Identifiable {
    let id: String
    let title: String
    let content: String
    let location: String
    let date: Date
    let type: MemoryType
    let photoCount: Int
    let isFavorite: Bool
    
    enum MemoryType {
        case journal
        case roadTrip
        case photo
    }
}

struct MemoryCard: View {
    let memory: MemoryItem
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(memory.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text(memory.location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(memory.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Type indicator
                Image(systemName: memory.type == .journal ? "book.fill" : "car.fill")
                    .font(.title3)
                    .foregroundColor(memory.type == .journal ? .purple : .blue)
            }
            
            // Content
            Text(memory.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(isExpanded ? nil : 3)
            
            // Actions
            HStack {
                // Photo count
                if memory.photoCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "photo")
                            .font(.caption)
                        Text("\(memory.photoCount)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Expand/Collapse
                if memory.content.count > 100 {
                    Button(isExpanded ? "Show Less" : "Show More") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                
                // Favorite button
                Button(action: {
                    // Toggle favorite
                }) {
                    Image(systemName: memory.isFavorite ? "heart.fill" : "heart")
                        .font(.caption)
                        .foregroundColor(memory.isFavorite ? .red : .secondary)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct MemoryFilterTab: View {
    let filter: MemoryFeedView.FeedFilter
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.caption)
                Text(filter.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.green : Color.gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyFeedView: View {
    let filter: MemoryFeedView.FeedFilter
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No memories found")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            Text(emptyMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 60)
    }
    
    private var emptyMessage: String {
        switch filter {
        case .recent:
            return "Start creating memories by scanning NFC tags or writing journal entries"
        case .byTrip:
            return "No road trip memories yet. Start a new road trip to see them here"
        case .byCountry:
            return "No memories organized by country yet"
        case .favorites:
            return "No favorite memories yet. Tap the heart icon on any memory to add it to favorites"
        }
    }
}

struct FilterSheet: View {
    @Binding var selectedFilter: MemoryFeedView.FeedFilter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Filter Memories") {
                    ForEach(MemoryFeedView.FeedFilter.allCases, id: \.self) { filter in
                        HStack {
                            Image(systemName: filter.icon)
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            Text(filter.rawValue)
                            
                            Spacer()
                            
                            if selectedFilter == filter {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFilter = filter
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MemoryFeedView()
        .environmentObject(JournalStore())
        .environmentObject(RoadTripService())
}
