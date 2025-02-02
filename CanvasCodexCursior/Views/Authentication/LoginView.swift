import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthenticationService
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var email = ""
    @State private var password = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Logo Section
                    VStack(spacing: 16) {
                        Image(systemName: "paintpalette")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        
                        Text("Canvas Codex")
                            .font(.title.bold())
                    }
                    
                    // Form Section
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            AuthTextField(
                                label: "Email",
                                placeholder: "Enter your email",
                                icon: "envelope",
                                text: $email
                            )
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .disabled(isLoading)
                            
                            AuthTextField(
                                label: "Password",
                                placeholder: "Enter your password",
                                icon: "lock",
                                isSecureField: true,
                                text: $password
                            )
                            .disabled(isLoading)
                            
                            Button("Forgot Password?") {
                                // Handle forgot password
                            }
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .disabled(isLoading)
                        }
                        .padding(.horizontal)
                        
                        // Sign In Button
                        AuthButton(
                            title: isLoading ? "Signing In..." : "Sign In",
                            icon: "arrow.right",
                            action: handleSignIn
                        )
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        print("👆 LoginView: Cancel tapped")
                        dismiss()
                    }
                    .disabled(isLoading)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onChange(of: authService.isAuthenticated) { isAuthenticated in
                print("👀 LoginView: Auth state changed to: \(isAuthenticated)")
                if isAuthenticated {
                    print("👀 LoginView: User is authenticated, dismissing")
                    hasSeenOnboarding = true
                    isLoading = false
                    dismiss()
                }
            }
            .onAppear {
                print("👀 LoginView: Appeared")
                print("👀 LoginView: Current auth state: \(authService.isAuthenticated)")
            }
        }
    }
    
    @MainActor
    private func handleSignIn() {
        guard !email.isEmpty && !password.isEmpty else { return }
        
        print("👆 LoginView: Sign in attempt with email: \(email)")
        isLoading = true
        
        Task {
            do {
                print("👆 LoginView: Calling auth service signIn")
                try await authService.signIn(email: email, password: password)
                print("👆 LoginView: Sign in completed successfully")
            } catch {
                print("❌ LoginView: Sign in failed with error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                showingError = true
                isLoading = false
            }
        }
    }
}

enum SocialAuthProvider {
    case apple
}

struct SocialLoginButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .foregroundColor(.primary)
    }
}

