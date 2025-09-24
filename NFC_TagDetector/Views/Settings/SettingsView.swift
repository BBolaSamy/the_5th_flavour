import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("autoBackupEnabled") private var autoBackupEnabled = true
    @State private var showingProfileEditor = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    ProfileHeaderView()
                        .onTapGesture {
                            showingProfileEditor = true
                        }
                }
                
                // Appearance Section
                Section("Appearance") {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        
                        Text("Dark Mode")
                        
                        Spacer()
                        
                        Toggle("", isOn: $isDarkMode)
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("Push Notifications")
                        
                        Spacer()
                        
                        Toggle("", isOn: $notificationsEnabled)
                    }
                    
                    HStack {
                        Image(systemName: "photo.fill")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        Text("Memory Reminders")
                        
                        Spacer()
                        
                        Toggle("", isOn: $notificationsEnabled)
                    }
                }
                
                // Data & Storage Section
                Section("Data & Storage") {
                    HStack {
                        Image(systemName: "icloud.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Auto Backup")
                        
                        Spacer()
                        
                        Toggle("", isOn: $autoBackupEnabled)
                    }
                    
                    NavigationLink(destination: StorageManagementView()) {
                        HStack {
                            Image(systemName: "externaldrive.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            
                            Text("Storage Management")
                        }
                    }
                }
                
                // AI & API Section
                Section("AI & API") {
                    NavigationLink(destination: APIKeySettingsView()) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.purple)
                                .frame(width: 24)
                            
                            Text("OpenAI API Key")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                
                // Privacy & Security Section
                Section("Privacy & Security") {
                    NavigationLink(destination: PrivacySettingsView()) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text("Privacy Settings")
                        }
                    }
                    
                    NavigationLink(destination: DataExportView()) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Export Data")
                        }
                    }
                }
                
                // Support Section
                Section("Support") {
                    NavigationLink(destination: HelpView()) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Help & FAQ")
                        }
                    }
                    
                    NavigationLink(destination: ContactView()) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            Text("Contact Support")
                        }
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            
                            Text("About")
                        }
                    }
                }
                
                // Account Section
                Section("Account") {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .sheet(isPresented: $showingProfileEditor) {
                ProfileEditorView()
                    .environmentObject(authService)
            }
            .alert("Sign Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authService.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

struct ProfileHeaderView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            AsyncImage(url: URL(string: authService.currentUser?.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(authService.currentUser?.name ?? "User")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(authService.currentUser?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Member since \(authService.currentUser?.createdAt.formatted(date: .abbreviated, time: .omitted) ?? "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct ProfileEditorView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Information") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Enter name", text: $name)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Email")
                        Spacer()
                        TextField("Enter email", text: $email)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.emailAddress)
                    }
                }
                
                Section("Profile Photo") {
                    Button("Change Photo") {
                        showingImagePicker = true
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
        .onAppear {
            name = authService.currentUser?.name ?? ""
            email = authService.currentUser?.email ?? ""
        }
    }
    
    private func saveProfile() {
        authService.updateProfile(name: name, profileImageURL: nil)
        dismiss()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// Placeholder views for navigation destinations
struct StorageManagementView: View {
    var body: some View {
        Text("Storage Management")
            .navigationTitle("Storage")
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        Text("Privacy Settings")
            .navigationTitle("Privacy")
    }
}

struct DataExportView: View {
    var body: some View {
        Text("Data Export")
            .navigationTitle("Export Data")
    }
}

struct HelpView: View {
    var body: some View {
        Text("Help & FAQ")
            .navigationTitle("Help")
    }
}

struct ContactView: View {
    var body: some View {
        Text("Contact Support")
            .navigationTitle("Contact")
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("NFC Tag Detector")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Connect your travel memories with NFC technology")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthService())
}
