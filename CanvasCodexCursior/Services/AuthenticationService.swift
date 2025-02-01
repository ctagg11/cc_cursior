import FirebaseAuth
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
    
    func signInWithApple() async throws {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
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
