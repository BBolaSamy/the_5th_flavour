import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // App Logo/Title
                VStack(spacing: 16) {
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("NFC Tag Detector")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Connect your travel memories with NFC")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Login Form
                VStack(spacing: 16) {
                    if showingSignUp {
                        TextField("Full Name", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Primary Action Button
                    Button(action: {
                        print("🔑 LoginView: Login button tapped")
                        if showingSignUp {
                            authService.signUpWithEmail(email: email, password: password, name: email)
                        } else {
                            authService.signInWithEmail(email: email, password: password)
                        }
                    }) {
                        HStack {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(showingSignUp ? "Create Account" : "Sign In")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
                    
                    // Toggle Sign Up/Sign In
                    Button(action: {
                        showingSignUp.toggle()
                        authService.errorMessage = nil
                    }) {
                        Text(showingSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal, 32)
                
                // Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                    
                    Text("or")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                }
                .padding(.horizontal, 32)
                
                // Social Login Buttons
                VStack(spacing: 12) {
                    SocialLoginButton(
                        title: "Sign in with Apple",
                        icon: "applelogo",
                        backgroundColor: .black,
                        foregroundColor: .white
                    ) {
                        authService.signInWithApple()
                    }
                    
                    SocialLoginButton(
                        title: "Sign in with Google",
                        icon: "globe",
                        backgroundColor: .white,
                        foregroundColor: .black
                    ) {
                        authService.signInWithGoogle()
                    }
                    
                    SocialLoginButton(
                        title: "Sign in with Facebook",
                        icon: "globe",
                        backgroundColor: Color(red: 0.26, green: 0.40, blue: 0.70),
                        foregroundColor: .white
                    ) {
                        authService.signInWithFacebook()
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Error Message
                if let errorMessage = authService.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            // Check if user is already authenticated
            if authService.isAuthenticated {
                // Navigate to main app
            }
        }
    }
}

struct SocialLoginButton: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService())
}
