import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var journalStore: JournalStore
    @EnvironmentObject var roadTripService: RoadTripService
    
    var body: some View {
        SettingsView()
            .environmentObject(authService)
    }
}

struct InfoPill: View {
    var icon: String
    var label: String

    var body: some View {
        Label(label, systemImage: icon)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.uberSecondaryBackground)
            .foregroundColor(.uberTextPrimary)
            .clipShape(Capsule())
    }
}

struct ProfileSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.uberTextSecondary)
            VStack {
                content
            }
            .padding()
            .background(Color.uberSecondaryBackground)
            .cornerRadius(12)
        }
    }
}
