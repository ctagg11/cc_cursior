//
//  CanvasCodexCursiorApp.swift
//  CanvasCodexCursior
//
//  Created by Charles Taggart on 1/22/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct CanvasCodexCursiorApp: App {
    @StateObject private var authService = AuthenticationService()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    let persistenceController = PersistenceController.shared
    
    init() {
        FirebaseBootstrap.configure()
        print("📱 App: Starting")
        print("📱 App: hasSeenOnboarding: \(hasSeenOnboarding)")
        print("📱 App: Auth state: \(Auth.auth().currentUser != nil)")
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    MainTabView()
                        .onAppear {
                            print("📱 App: Showing MainTabView")
                            hasSeenOnboarding = true // Ensure this is set if authenticated
                        }
                } else if !hasSeenOnboarding {
                    EnhancedOnboardingView()
                        .onDisappear {
                            print("📱 App: Onboarding disappeared")
                            hasSeenOnboarding = true
                        }
                        .onAppear {
                            print("📱 App: Showing Onboarding")
                        }
                } else {
                    AuthenticationCoordinator()
                        .onAppear {
                            print("📱 App: Showing AuthenticationCoordinator")
                        }
                }
            }
            .environmentObject(authService)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

#if DEBUG
// Debug helper to reset all states
extension UserDefaults {
    static func resetDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}
#endif





