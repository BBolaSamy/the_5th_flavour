import SwiftUI

struct HomeView: View {
    @EnvironmentObject var mediaManager: MediaManager
    @EnvironmentObject var journalStore: JournalStore
    @EnvironmentObject var roadTripService: RoadTripService
    @State private var showingNFCScan = false
    @State private var showingRoadTripSetup = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Header
                    VStack(spacing: 8) {
                        Text("Welcome back!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Ready to capture more memories?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Quick Actions
                    VStack(spacing: 16) {
                        Text("Quick Actions")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 12) {
                            QuickActionCard(
                                title: "Scan NFC Tag",
                                subtitle: "Add memories",
                                icon: "waveform.circle",
                                color: .green
                            ) {
                                showingNFCScan = true
                            }
                            
                            QuickActionCard(
                                title: "Start Trip",
                                subtitle: "New road trip",
                                icon: "car",
                                color: .blue
                            ) {
                                showingRoadTripSetup = true
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Current Trip
                    if let currentTrip = roadTripService.currentTrip {
                        VStack(spacing: 16) {
                            Text("Current Trip")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            CurrentTripCard(trip: currentTrip)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent Activity
                    VStack(spacing: 16) {
                        Text("Recent Activity")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if journalStore.entries.isEmpty {
                            EmptyActivityView()
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(journalStore.entries.prefix(5)) { entry in
                                    RecentActivityCard(entry: entry)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Statistics
                    VStack(spacing: 16) {
                        Text("Your Memories")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 12) {
                            HomeStatCard(
                                title: "\(journalStore.entries.count)",
                                subtitle: "Journal Entries",
                                icon: "book",
                                color: .purple
                            )
                            
                            HomeStatCard(
                                title: "\(roadTripService.allTrips.count)",
                                subtitle: "Road Trips",
                                icon: "car",
                                color: .blue
                            )
                            
                            HomeStatCard(
                                title: "\(mediaManager.cityGroupedMedia.values.flatMap { $0.values }.flatMap { $0 }.count)",
                                subtitle: "Photos",
                                icon: "photo",
                                color: .green
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 100) // Space for tab bar
            }
            .navigationTitle("NFC Tag Detector")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingNFCScan) {
                NFCScanFlowView()
            }
            .sheet(isPresented: $showingRoadTripSetup) {
                RoadTripSetupView()
            }
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CurrentTripCard: View {
    let trip: RoadTrip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(trip.duration) days • \(trip.cities.count) cities")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "car.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
            // Progress
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(trip.cities.count) of \(trip.duration) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: Double(trip.cities.count), total: Double(trip.duration))
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
            }
            
            // Cities
            if !trip.cities.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(trip.cities) { city in
                            CityChip(city: city)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct CityChip: View {
    let city: TripCity
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "location.fill")
                .font(.caption2)
            Text(city.name)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.green.opacity(0.1))
        .foregroundColor(.green)
        .cornerRadius(8)
    }
}

struct RecentActivityCard: View {
    let entry: JournalEntry
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.title3)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(entry.region)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(entry.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct HomeStatCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct EmptyActivityView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No recent activity")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Start scanning NFC tags or create your first journal entry")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    HomeView()
        .environmentObject(MediaManager())
        .environmentObject(JournalStore())
        .environmentObject(RoadTripService())
}
