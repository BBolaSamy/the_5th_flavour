import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let profileImageURL: String?
    let createdAt: Date
    let lastLoginAt: Date
    
    init(id: String, email: String, name: String, profileImageURL: String? = nil, createdAt: Date = Date(), lastLoginAt: Date = Date()) {
        self.id = id
        self.email = email
        self.name = name
        self.profileImageURL = profileImageURL
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
    }
}

enum AuthProvider: String, CaseIterable {
    case email = "email"
    case apple = "apple"
    case google = "google"
    case facebook = "facebook"
    
    var displayName: String {
        switch self {
        case .email: return "Email"
        case .apple: return "Sign in with Apple"
        case .google: return "Google"
        case .facebook: return "Facebook"
        }
    }
    
    var iconName: String {
        switch self {
        case .email: return "envelope"
        case .apple: return "applelogo"
        case .google: return "globe"
        case .facebook: return "globe"
        }
    }
}
