import Foundation

enum ComponentType: String, CaseIterable, Identifiable {
    case subject = "subject"
    case process = "process"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .subject:
            return "mountain.2"
        case .process:
            return "paintbrush.fill"
        }
    }
    
    var title: String {
        switch self {
        case .subject:
            return "Subject"
        case .process:
            return "Technique"
        }
    }
    
    var description: String {
        switch self {
        case .subject:
            return "Tag what was drawn"
        case .process:
            return "Tag techniques used"
        }
    }
} 