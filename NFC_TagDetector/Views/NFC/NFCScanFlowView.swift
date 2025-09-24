import SwiftUI
import CoreNFC

struct NFCScanFlowView: View {
    @State private var isScanning = false
    @State private var scannedTagID: String?
    @State private var showingMediaOptions = false
    @State private var selectedCity: String = ""
    @State private var showingCitySearch = false
    
    var body: some View {
        VStack(spacing: 24) {
            if !isScanning && scannedTagID == nil {
                // Initial scan state
                VStack(spacing: 20) {
                    Image(systemName: "waveform.circle")
                        .font(.system(size: 100))
                        .foregroundColor(.green)
                    
                    Text("Scan NFC Tag")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Hold your device near an NFC tag to begin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: startScanning) {
                        HStack {
                            Image(systemName: "waveform.circle")
                            Text("Start Scanning")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                }
            } else if isScanning {
                // Scanning state
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                    
                    Text("Scanning for NFC tag...")
                        .font(.headline)
                    
                    Text("Hold your device near the tag")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Cancel") {
                        stopScanning()
                    }
                    .foregroundColor(.red)
                }
            } else if let tagID = scannedTagID {
                // Tag scanned - show media options
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("Tag Scanned Successfully!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Tag ID: \(tagID)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text("How would you like to add your memories for this location?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        MediaOptionButton(
                            title: "Manually add photos/videos",
                            subtitle: "Select from your gallery",
                            icon: "photo.on.rectangle",
                            color: .blue
                        ) {
                            // Navigate to manual media selection
                        }
                        
                        MediaOptionButton(
                            title: "Let app fetch from gallery",
                            subtitle: "Auto-detect photos within 50km",
                            icon: "location.magnifyingglass",
                            color: .green
                        ) {
                            showingCitySearch = true
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Button("Scan Another Tag") {
                        resetScan()
                    }
                    .foregroundColor(.green)
                }
            }
        }
        .padding()
        .sheet(isPresented: $showingCitySearch) {
            CitySearchView(selectedCity: $selectedCity)
        }
    }
    
    private func startScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            // Show error - NFC not available
            return
        }
        
        isScanning = true
        scannedTagID = nil
        
        // Create new NFC handler for this scan
        let handler = NFCDelegateHandler(
            onTagScanned: { tagID in
                DispatchQueue.main.async {
                    self.scannedTagID = tagID
                    self.isScanning = false
                }
            },
            onTimeout: {
                DispatchQueue.main.async {
                    self.isScanning = false
                }
            }
        )
        
        // Start NFC session
        let session = NFCNDEFReaderSession(delegate: handler, queue: nil, invalidateAfterFirstRead: true)
        session.alertMessage = "Hold your device near the NFC tag"
        session.begin()
    }
    
    private func stopScanning() {
        isScanning = false
    }
    
    private func resetScan() {
        scannedTagID = nil
        isScanning = false
    }
}

struct MediaOptionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    NFCScanFlowView()
}
