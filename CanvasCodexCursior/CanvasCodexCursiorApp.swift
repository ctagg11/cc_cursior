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
    
    init() {
        FirebaseBootstrap.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(authService)
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}



// if i want to skip auth each time:


//var body: some Scene {
//    WindowGroup {
//        // For testing, force ContentView
//        ContentView()
//            .environmentObject(authService)
//        // Normal authentication flow
//        //if authService.isAuthenticated {
//        //    ContentView()
//        //        .environmentObject(authService)
//        //} else {
//        //    LoginView()
//        //        .environmentObject(authService)
//        //}
//    }
//}
