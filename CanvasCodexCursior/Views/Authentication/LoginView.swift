import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = true
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo/Header Section
                    VStack(spacing: 12) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.Colors.primary)
                        
                        Text("Canvas Codex")
                            .font(.title.bold())
                    }
                    .padding(.top, 40)
                    
                    // Form Sections wrapped in a card
                    VStack(spacing: 24) {
                        // Sign Up/In Form
                        FormSection(
                            title: isSignUp ? "Create Account" : "Welcome Back",
                            description: isSignUp ? "Start your artistic journey" : "Sign in to continue"
                        ) {
                            VStack(spacing: 16) {
                                AppTextField(
                                    label: "Email",
                                    placeholder: "Enter your email",
                                    text: $email,
                                    icon: "envelope"
                                )
                                
                                AppTextField(
                                    label: "Password",
                                    placeholder: "Enter your password",
                                    text: $password,
                                    icon: "lock",
                                    isSecureField: true
                                )
                                
                                AppButton(
                                    title: isSignUp ? "Create Account" : "Sign In",
                                    style: .primary
                                ) {
                                    Task {
                                        do {
                                            if isSignUp {
                                                try await authService.createAccount(email: email, password: password)
                                            } else {
                                                try await authService.signIn(email: email, password: password)
                                            }
                                        } catch {
                                            errorMessage = error.localizedDescription
                                            showError = true
                                        }
                                    }
                                }
                                
                                Button(isSignUp ? "Already have an account? Sign In" : "Need an account? Sign Up") {
                                    isSignUp.toggle()
                                }
                                .foregroundColor(AppTheme.Colors.primary)
                            }
                        }
                        
                        // Social Sign In Options
                        FormSection(
                            title: "Other Options",
                            description: "Continue with your social account"
                        ) {
                            HStack(spacing: 20) {
                                SocialSignInButton(
                                    type: .google,
                                    authService: authService,
                                    errorMessage: $errorMessage,
                                    showError: $showError
                                )
                                SocialSignInButton(
                                    type: .apple,
                                    authService: authService,
                                    errorMessage: $errorMessage,
                                    showError: $showError
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 24)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }
}

struct SocialSignInButton: View {
    enum SignInType {
        case google
        case apple
        
        var image: String {
            switch self {
            case .google: return "google"
            case .apple: return "apple.logo"
            }
        }
        
        var text: String {
            switch self {
            case .google: return "Google"
            case .apple: return "Apple"
            }
        }
    }
    
    let type: SignInType
    let authService: AuthenticationService
    @Binding var errorMessage: String
    @Binding var showError: Bool
    
    var body: some View {
        Button {
            Task {
                do {
                    switch type {
                    case .google:
                        try await authService.signInWithGoogle()
                    case .apple:
                        try await authService.signInWithApple()
                    }
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        } label: {
            HStack {
                Image(systemName: type.image)
                Text(type.text)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(AppTheme.Layout.cornerRadius)
        }
    }
} 