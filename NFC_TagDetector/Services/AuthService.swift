import Foundation
import SwiftUI
import AuthenticationServices
import Combine

@MainActor
class AuthService: NSObject, ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        // Check for existing authentication state
        checkAuthState()
    }
    
    // MARK: - Authentication State
    
    private func checkAuthState() {
        // For now, we'll use a simple mock implementation
        // In a real app, you'd check Firebase Auth or Keychain
        if let savedUser = loadUserFromKeychain() {
            currentUser = savedUser
            isAuthenticated = true
        }
    }
    
    // MARK: - Email Authentication
    
    func signInWithEmail(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Mock implementation - replace with Firebase Auth
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let user = User(id: UUID().uuidString, email: email, name: email.components(separatedBy: "@").first ?? "User")
            self.handleSuccessfulAuth(user: user)
        }
    }
    
    func signUpWithEmail(email: String, password: String, name: String) {
        isLoading = true
        errorMessage = nil
        
        // Mock implementation - replace with Firebase Auth
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let user = User(id: UUID().uuidString, email: email, name: name)
            self.handleSuccessfulAuth(user: user)
        }
    }
    
    // MARK: - Social Authentication
    
    func signInWithApple() {
        isLoading = true
        errorMessage = nil
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        // Mock implementation - replace with Google Sign-In SDK
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let user = User(id: UUID().uuidString, email: "user@gmail.com", name: "Google User")
            self.handleSuccessfulAuth(user: user)
        }
    }
    
    func signInWithFacebook() {
        isLoading = true
        errorMessage = nil
        
        // Mock implementation - replace with Facebook SDK
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let user = User(id: UUID().uuidString, email: "user@facebook.com", name: "Facebook User")
            self.handleSuccessfulAuth(user: user)
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        clearUserFromKeychain()
    }
    
    // MARK: - Profile Management
    
    func updateProfile(name: String, profileImageURL: String? = nil) {
        guard let user = currentUser else { return }
        
        // Create updated user
        let updatedUser = User(
            id: user.id,
            email: user.email,
            name: name,
            profileImageURL: profileImageURL ?? user.profileImageURL,
            createdAt: user.createdAt,
            lastLoginAt: Date()
        )
        
        currentUser = updatedUser
        saveUserToKeychain(updatedUser)
    }
    
    // MARK: - Private Helpers
    
    private func handleSuccessfulAuth(user: User) {
        print("🔐 AuthService: Setting user as authenticated")
        currentUser = user
        isAuthenticated = true
        isLoading = false
        saveUserToKeychain(user)
        print("🔐 AuthService: isAuthenticated = \(isAuthenticated), user = \(user.email)")
    }
    
    private func handleAuthError(_ error: Error) {
        errorMessage = error.localizedDescription
        isLoading = false
    }
    
    // MARK: - Keychain Storage
    
    private func saveUserToKeychain(_ user: User) {
        do {
            let data = try JSONEncoder().encode(user)
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "current_user",
                kSecValueData as String: data
            ]
            
            // Delete existing item
            SecItemDelete(query as CFDictionary)
            
            // Add new item
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                print("Failed to save user to keychain: \(status)")
            }
        } catch {
            print("Failed to encode user: \(error)")
        }
    }
    
    private func loadUserFromKeychain() -> User? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "current_user",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        
        return user
    }
    
    private func clearUserFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "current_user"
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            let name = [fullName?.givenName, fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            
            let user = User(
                id: userIdentifier,
                email: email ?? "apple@privaterelay.appleid.com",
                name: name.isEmpty ? "Apple User" : name
            )
            
            handleSuccessfulAuth(user: user)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        handleAuthError(error)
    }
}
