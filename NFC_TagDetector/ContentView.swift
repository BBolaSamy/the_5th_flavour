import Foundation
import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService()
    @StateObject private var mediaManager = MediaManager()
    @StateObject private var journalStore = JournalStore()
    @StateObject private var roadTripService = RoadTripService()

    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(authService)
                    .environmentObject(mediaManager)
                    .environmentObject(journalStore)
                    .environmentObject(roadTripService)
                    .onAppear {
                        print("🏠 ContentView: Showing MainTabView - User is authenticated")
                    }
            } else {
                LoginView()
                    .environmentObject(authService)
                    .onAppear {
                        print("🔑 ContentView: Showing LoginView - User is not authenticated")
                    }
            }
        }
        .onChange(of: authService.isAuthenticated) { isAuthenticated in
            print("🔄 ContentView: Authentication state changed to: \(isAuthenticated)")
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var mediaManager: MediaManager
    @EnvironmentObject var journalStore: JournalStore
    @EnvironmentObject var roadTripService: RoadTripService
    
    var body: some View {
        TabView {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .environmentObject(mediaManager)
                .environmentObject(journalStore)
                .environmentObject(roadTripService)

            // NFC Scan Tab
            NFCScanFlowView()
                .tabItem {
                    Label("Scan", systemImage: "waveform.circle")
                }

            // Road Trip Tab
            if roadTripService.currentTrip != nil {
                CityNavigationView(cities: roadTripService.currentTrip?.cities ?? [])
                    .tabItem {
                        Label("Trip", systemImage: "car")
                    }
                    .environmentObject(roadTripService)
            } else {
                RoadTripSetupView()
                    .tabItem {
                        Label("Trip", systemImage: "car")
                    }
                    .environmentObject(roadTripService)
            }

            // Map Tab
            EnhancedWorldMapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .environmentObject(journalStore)
                .environmentObject(roadTripService)

            // Memories Tab
            MemoryFeedView()
                .tabItem {
                    Label("Memories", systemImage: "heart")
                }
                .environmentObject(journalStore)
                .environmentObject(roadTripService)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .environmentObject(authService)
        }
        .accentColor(Color.green)
    }
}
