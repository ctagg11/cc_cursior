//
//  CanvasCodexCursiorApp.swift
//  CanvasCodexCursior
//
//  Created by Charles Taggart on 1/22/25.
//

import SwiftUI

@main
struct CanvasCodexCursiorApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
