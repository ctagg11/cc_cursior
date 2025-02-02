import FirebaseAuth
import FirebaseCore

@MainActor
class AuthenticationService: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        print("🔐 AuthService: Initializing")
        registerAuthStateHandler()
    }
    
    private func registerAuthStateHandler() {
        if handle == nil {
            print("🔐 AuthService: Setting up auth state listener")
            handle = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
                Task { @MainActor in
                    print("🔐 AuthService: Auth state changed - User: \(user?.email ?? "nil")")
                    self?.user = user
                    self?.isAuthenticated = user != nil
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        print("🔐 AuthService: Attempting sign in with email: \(email)")
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        await MainActor.run {
            print("🔐 AuthService: Sign in successful")
            self.user = result.user
            self.isAuthenticated = true
            print("🔐 AuthService: Updated auth state - isAuthenticated: \(self.isAuthenticated)")
        }
    }
    
    func createAccount(email: String, password: String) async throws {
        print("🔐 AuthService: Creating account for email: \(email)")
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        await MainActor.run {
            self.user = result.user
            self.isAuthenticated = true
        }
    }
    
    func signOut() throws {
        print("🔐 AuthService: Signing out")
        try Auth.auth().signOut()
        Task { @MainActor in
            self.user = nil
            self.isAuthenticated = false
        }
    }
} 
