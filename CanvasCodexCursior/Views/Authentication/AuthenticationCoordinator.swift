import SwiftUI

enum AuthenticationFlow: Identifiable {
    case login
    case signup
    case forgotPassword
    
    var id: String {
        switch self {
        case .login: return "login"
        case .signup: return "signup"
        case .forgotPassword: return "forgotPassword"
        }
    }
}

struct AuthenticationCoordinator: View {
    @State private var activeFlow: AuthenticationFlow?
    @State private var preferences = OnboardingPreferences()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                AuthHeader(
                    title: "Canvas Codex",
                    subtitle: "Your digital art companion"
                )
                
                VStack(spacing: 16) {
                    AuthButton(
                        title: "Get Started",
                        icon: "paintpalette",
                        style: .primary
                    ) {
                        activeFlow = .signup
                    }
                    
                    AuthButton(
                        title: "I already have an account",
                        style: .secondary
                    ) {
                        activeFlow = .login
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .sheet(item: $activeFlow) { flow in
            switch flow {
            case .login:
                LoginView()
            case .signup:
                SignupFlow(preferences: $preferences)
            case .forgotPassword:
                ForgotPasswordView()
            }
        }
    }
} 