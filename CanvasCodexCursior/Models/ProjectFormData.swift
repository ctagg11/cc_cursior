import Foundation
import UIKit

struct ProjectFormData {
    var name = ""
    var medium = ""
    var startDate = Date()
    var inspiration = ""
    var references: [ReferenceImage] = []
    var learningGoals = ""
    var skills = ""
    var timeEstimate = TimeEstimate.singleSession
    var priority = ProjectPriority.medium
}

struct ReferenceImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

enum TimeEstimate: String, CaseIterable {
    case quickSketch
    case singleSession
    case multiDay
    case extended
    
    var description: String {
        switch self {
        case .quickSketch: return "Quick Sketch (1-2 hours)"
        case .singleSession: return "Single Session (2-4 hours)"
        case .multiDay: return "Multi-Day Project"
        case .extended: return "Extended Project"
        }
    }
}

enum ProjectPriority: String, CaseIterable {
    case high
    case medium
    case low
    case experimental
    
    var description: String {
        rawValue.capitalized
    }
} 