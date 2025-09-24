# 🏷️ NFC TagDetector

A native iOS app that connects NFC-embedded souvenir frames to a digital travel journal. Transform your physical travel memories into an interactive digital experience with AI-powered journal generation, smart media organization, and beautiful visualizations.

![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0+-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## ✨ Features

### 🔐 **Authentication & User Management**
- Email & Password authentication
- Social login (Apple, Google, Facebook)
- Secure user profile management
- iOS Keychain integration

### 📱 **NFC Tag Detection**
- CoreNFC integration for tag scanning
- Automatic media linking to locations
- Smart media selection (manual/auto-fetch)
- 50km radius media retrieval

### 🧠 **AI-Powered Journal Generation**
- OpenAI GPT-4 integration
- Context-aware journal creation
- Metadata-driven content generation
- Customizable writing styles

### 🗺️ **Interactive Maps & Navigation**
- World map with location pins
- City-based media organization
- Road trip visualization
- Interactive route mapping

### 📸 **Smart Media Management**
- PhotoKit integration
- Location-based media grouping
- Fullscreen media viewer
- Batch media selection

### 🎯 **Road Trip Mode**
- Date range trip planning
- City-by-city navigation
- Interactive trip visualization
- Media timeline organization

## 🚀 Getting Started

### Prerequisites

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+
- OpenAI API key (for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/BBolaSamy/the_5th_flavour.git
   cd the_5th_flavour
   ```

2. **Open in Xcode**
   ```bash
   open NFC_TagDetector.xcodeproj
   ```

3. **Configure API Keys**
   - See [API_KEY_SETUP.md](API_KEY_SETUP.md) for detailed instructions
   - Set up your OpenAI API key securely

4. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd + R` to build and run

## 🔧 Configuration

### OpenAI API Key Setup

The app supports multiple secure methods for API key storage:

#### Option 1: Environment Variable (Recommended for Development)
```bash
export OPENAI_API_KEY="your_openai_api_key_here"
```

#### Option 2: iOS Keychain (Most Secure)
1. Open the app → Settings → "AI & API" → "OpenAI API Key"
2. Enter your API key in the secure text field
3. Tap "Store in Keychain"

#### Option 3: Info.plist (Development Only)
Add to your `Info.plist`:
```xml
<key>OpenAIAPIKey</key>
<string>your_api_key_here</string>
```

## 📱 App Structure

```
NFC_TagDetector/
├── Models/                 # Data models
│   ├── User.swift
│   └── RoadTrip.swift
├── Services/              # Business logic
│   ├── AuthService.swift
│   ├── GPTService.swift
│   ├── KeychainHelper.swift
│   └── PhotoPermissionService.swift
├── Views/                 # SwiftUI views
│   ├── Auth/             # Authentication views
│   ├── Home/             # Home screen
│   ├── NFC/              # NFC scanning
│   ├── Journal/          # Journal creation
│   ├── Map/              # Map views
│   ├── Media/            # Media management
│   ├── Navigation/       # Navigation components
│   ├── RoadTrip/         # Road trip features
│   ├── Search/           # City search
│   └── Settings/         # Settings & configuration
└── Resources/            # Assets and resources
```

## 🎯 Core Functionality

### 1. **NFC Tag Scanning**
- Scan NFC-embedded souvenir frames
- Link physical objects to digital memories
- Automatic location detection

### 2. **AI Journal Generation**
- Context-aware content creation
- Metadata-driven prompts
- Customizable writing styles
- Rich text and photo layouts

### 3. **Smart Media Organization**
- Location-based grouping
- Automatic metadata extraction
- Batch operations
- Fullscreen viewing

### 4. **Interactive Maps**
- World map with location pins
- City thumbnails and details
- Route visualization
- Interactive navigation

### 5. **Road Trip Planning**
- Date range selection
- City-by-city organization
- Media timeline
- Interactive trip mapping

## 🔒 Security Features

- **iOS Keychain Integration**: Secure API key storage
- **Environment Variables**: Development-friendly configuration
- **No Hardcoded Keys**: All sensitive data stored securely
- **User Privacy**: Local data processing with optional cloud sync

## 🛠️ Technical Stack

- **UI Framework**: SwiftUI
- **AI Integration**: OpenAI GPT-4
- **Maps**: MapKit
- **NFC**: CoreNFC
- **Media**: PhotoKit
- **Authentication**: Sign in with Apple, Firebase Auth
- **Storage**: CoreData, CloudKit
- **Architecture**: MVVM + Combine

## 📋 Requirements

### iOS Requirements
- iOS 15.0 or later
- iPhone, iPad, or iPod touch
- NFC capability (for tag scanning)

### Development Requirements
- Xcode 14.0 or later
- Swift 5.0 or later
- macOS 12.0 or later

## 🚀 Deployment

### App Store Deployment
1. Configure production API keys
2. Update bundle identifier
3. Set up App Store Connect
4. Archive and upload

### Enterprise Distribution
1. Configure enterprise certificates
2. Set up provisioning profiles
3. Build and distribute

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- OpenAI for GPT-4 API
- Apple for CoreNFC and SwiftUI frameworks
- The SwiftUI community for inspiration and support

## 📞 Support

For support, email support@nfc-tagdetector.com or create an issue in this repository.

## 🔮 Roadmap

- [ ] CloudKit synchronization
- [ ] Apple Watch companion app
- [ ] Advanced AI features
- [ ] Social sharing capabilities
- [ ] Offline mode support
- [ ] Multiple language support

---

**Made with ❤️ for travelers and memory keepers**
