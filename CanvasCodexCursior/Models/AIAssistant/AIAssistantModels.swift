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
    case chat = "Just Chat"
    
    var icon: String {
        switch self {
        case .reviewArt: return "photo.on.rectangle.angled"
        case .findInspiration: return "lightbulb.fill"
        case .chat: return "bubble.left.and.bubble.right.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .reviewArt: return .blue
        case .findInspiration: return .purple
        case .chat: return .green
        }
    }
    
    var description: String {
        switch self {
        case .reviewArt: return "Get detailed feedback on your artwork or work in progress"
        case .findInspiration: return "Explore references, color palettes, and creative concepts"
        case .chat: return "Have an open conversation about art, techniques, and creative ideas"
        }
    }
}

// MARK: - ArtworkSource
enum ArtworkSource: String, CaseIterable {
    case gallery = "Gallery Works"
    case workInProgress = "Work in Progress"
} 