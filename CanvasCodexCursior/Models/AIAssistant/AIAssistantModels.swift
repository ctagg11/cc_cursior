import SwiftUI

// MARK: - AIMessage
struct AIMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    var attachedImage: Image?
    var timestamp = Date()
    
    init(content: String, isUser: Bool, attachedImage: Image? = nil) {
        self.content = content
        self.isUser = isUser
        self.attachedImage = attachedImage
    }
}

// MARK: - QuickActionCategory
enum QuickActionCategory: String, CaseIterable {
    case reviewArt = "Review My Art"
    case findInspiration = "Find Inspiration"
    case learnTechniques = "Learn Techniques"
    case planProject = "Plan My Project"
    
    var icon: String {
        switch self {
        case .reviewArt: return "photo.on.rectangle.angled"
        case .findInspiration: return "lightbulb.fill"
        case .learnTechniques: return "paintbrush.fill"
        case .planProject: return "list.clipboard.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .reviewArt: return .blue
        case .findInspiration: return .purple
        case .learnTechniques: return .orange
        case .planProject: return .green
        }
    }
}

// MARK: - ArtworkSource
enum ArtworkSource: String, CaseIterable {
    case gallery = "Gallery Works"
    case workInProgress = "Work in Progress"
} 