import FirebaseCore

class FirebaseBootstrap {
    static func configure() {
        print("🔥 Configuring Firebase...")
        if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            print("📄 Found GoogleService-Info.plist at: \(filePath)")
        } else {
            print("❌ GoogleService-Info.plist not found in bundle!")
        }
        
        FirebaseApp.configure()
        
        if let clientID = FirebaseApp.app()?.options.clientID {
            print("✅ Firebase configured successfully with clientID: \(clientID)")
        } else {
            print("❌ Firebase configuration failed - no clientID found")
        }
    }
} 