import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import FirebaseCore

enum AuthenticationError: Error {
    case signInError(String)
    case signOutError(String)
    case noUser
}

class AuthenticationService: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    
    private var handle: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?
    
    init() {
        registerAuthStateHandler()
    }
    
    private func registerAuthStateHandler() {
        if handle == nil {
            handle = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
                self?.user = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        print("Attempting to sign in with email...")
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("Sign in successful")
            self.user = result.user
            self.isAuthenticated = true
        } catch {
            print("Sign in failed: \(error.localizedDescription)")
            throw AuthenticationError.signInError(error.localizedDescription)
        }
    }
    
    func createAccount(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
            self.isAuthenticated = true
        } catch {
            throw AuthenticationError.signInError(error.localizedDescription)
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            throw AuthenticationError.signOutError(error.localizedDescription)
        }
    }
    
    func signInWithGoogle() async throws {
        print("Starting Google sign-in process...")
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("❌ Failed to get clientID from Firebase config")
            throw AuthenticationError.signInError("Firebase configuration not found")
        }
        print("📱 Using clientID: \(clientID)")
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("❌ Failed to get root view controller")
            throw AuthenticationError.signInError("Unable to present sign in window")
        }
        
        do {
            print("🔄 Attempting to present Google sign-in...")
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            print("✅ Google sign-in UI completed")
            
            guard let idToken = try await result.user.idToken?.tokenString else {
                print("❌ Failed to get ID token from Google sign-in result")
                throw AuthenticationError.signInError("Failed to get ID token")
            }
            print("✅ Successfully got Google ID token")
            
            let accessToken = try await result.user.accessToken.tokenString
            print("✅ Successfully got access token")
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )
            print("🔄 Attempting to sign in with Firebase...")
            let authResult = try await Auth.auth().signIn(with: credential)
            print("✅ Firebase sign-in successful")
            
            await MainActor.run {
                self.user = authResult.user
                self.isAuthenticated = true
            }
        } catch {
            print("❌ Google sign-in error: \(error)")
            throw AuthenticationError.signInError(error.localizedDescription)
        }
    }
    
    func signInWithApple() async throws {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw AuthenticationError.signInError("No root view controller found")
        }
        
        do {
            let result = try await performAppleSignIn(request, on: rootViewController)
            guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential,
                  let nonce = currentNonce,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                throw AuthenticationError.signInError("Unable to fetch identity token")
            }
            
            let credential = OAuthProvider.credential(
                providerID: .apple,
                idToken: idTokenString,
                rawNonce: nonce
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            await MainActor.run {
                self.user = authResult.user
                self.isAuthenticated = true
            }
        } catch {
            throw AuthenticationError.signInError(error.localizedDescription)
        }
    }
    
    @MainActor
    private func performAppleSignIn(_ request: ASAuthorizationAppleIDRequest, on controller: UIViewController) async throws -> ASAuthorization {
        return try await withCheckedThrowingContinuation { continuation in
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            let delegate = AppleSignInDelegate(continuation: continuation)
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = delegate
            authorizationController.performRequests()
        }
    }
    
    // Helper for Apple Sign In
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
} 