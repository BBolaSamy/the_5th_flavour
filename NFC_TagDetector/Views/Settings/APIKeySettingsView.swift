import SwiftUI

struct APIKeySettingsView: View {
    @State private var apiKey = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isKeychainAvailable = false
    
    private let gptService = GPTService()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("OpenAI API Key")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter your OpenAI API key to enable AI journal generation")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        SecureField("API Key", text: $apiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        HStack {
                            Button("Store in Keychain") {
                                storeAPIKey()
                            }
                            .disabled(apiKey.isEmpty)
                            
                            Spacer()
                            
                            Button("Remove from Keychain") {
                                removeAPIKey()
                            }
                            .foregroundColor(.red)
                            .disabled(!isKeychainAvailable)
                        }
                    }
                }
                
                Section(header: Text("Security Information")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.green)
                            Text("Secure Storage")
                                .fontWeight(.medium)
                        }
                        
                        Text("Your API key is stored securely in the iOS Keychain and never shared or logged.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text("Important")
                                .fontWeight(.medium)
                        }
                        
                        Text("Never share your API key with others. Keep it secure and rotate it regularly.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("API Key Status")) {
                    HStack {
                        Image(systemName: gptService.isAPIKeyAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(gptService.isAPIKeyAvailable ? .green : .red)
                        
                        Text(gptService.isAPIKeyAvailable ? "API Key Available" : "No API Key Found")
                            .fontWeight(.medium)
                    }
                }
            }
            .navigationTitle("API Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkKeychainStatus()
            }
            .alert("API Key", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func storeAPIKey() {
        let success = gptService.storeAPIKeyInKeychain(apiKey)
        if success {
            alertMessage = "API key stored securely in Keychain"
            apiKey = "" // Clear the text field
            checkKeychainStatus()
        } else {
            alertMessage = "Failed to store API key. Please try again."
        }
        showingAlert = true
    }
    
    private func removeAPIKey() {
        let success = gptService.removeAPIKeyFromKeychain()
        if success {
            alertMessage = "API key removed from Keychain"
            checkKeychainStatus()
        } else {
            alertMessage = "Failed to remove API key. Please try again."
        }
        showingAlert = true
    }
    
    private func checkKeychainStatus() {
        isKeychainAvailable = KeychainHelper.shared.exists(key: "OpenAIAPIKey")
    }
}

#Preview {
    APIKeySettingsView()
}
