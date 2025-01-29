//
//  CanvasCodexCursiorApp.swift
//  CanvasCodexCursior
//
//  Created by Charles Taggart on 1/22/25.
//

import SwiftUI
import FirebaseCore

@main
struct CanvasCodexCursiorApp: App {
    @StateObject private var authService = AuthenticationService()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    let persistenceController = PersistenceController.shared
    
    init() {
        FirebaseBootstrap.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if !hasSeenOnboarding {
                OnboardingView()
                    .environmentObject(authService)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(authService)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                LoginView()
                    .environmentObject(authService)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}



