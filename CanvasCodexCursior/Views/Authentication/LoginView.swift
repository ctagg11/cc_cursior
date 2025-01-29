import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
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
                    FormSection(
                        title: isSignUp ? "Create Account" : "Welcome Back",
                        description: isSignUp ? "Start your artistic journey" : "Sign in to continue"
                    ) {
                        VStack(spacing: 16) {
                            AppTextField(
                                label: "Email",
                                placeholder: "Enter your email",
                                icon: "envelope",
                                text: $email
                            )
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .foregroundColor(.primary)
                            
                            AppTextField(
                                label: "Password",
                                placeholder: "Enter your password",
                                icon: "lock",
                                isSecureField: true,
                                text: $password
                            )
                            .foregroundColor(.primary)
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        AppButton(
                            title: isSignUp ? "Create Account" : "Sign In",
                            style: .primary
                        ) {
                            Task {
                                await handleAuthentication()
                            }
                        }
                        
                        // Social Login Options
                        VStack(spacing: 12) {
                            Text("Or continue with")
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 16) {
                                SocialLoginButton(
                                    title: "Sign in with Apple",
                                    icon: "apple.logo",
                                    action: handleAppleLogin
                                )
                                
                                SocialLoginButton(
                                    title: "Sign in with Google",
                                    icon: "g.circle.fill",
                                    action: handleGoogleLogin
                                )
                            }
                        }
                        
                        Button {
                            withAnimation {
                                isSignUp.toggle()
                            }
                        } label: {
                            Text(isSignUp ? "Already have an account? Sign In" : "New here? Create Account")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func handleAuthentication() async {
        do {
            if isSignUp {
                try await authService.createAccount(email: email, password: password)
            } else {
                try await authService.signIn(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func handleAppleLogin() {
        // ... existing Apple login code ...
    }
    
    private func handleGoogleLogin() {
        // ... existing Google login code ...
    }
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

