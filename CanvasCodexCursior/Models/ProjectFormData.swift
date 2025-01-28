import Foundation
import UIKit

struct ProjectFormData {
    var name: String = ""
    var medium: String = ""
    var startDate: Date = Date()
    var inspiration: String = ""
    var skills: String = ""
    var timeEstimate: TimeEstimate = .singleSession
    var priority: ProjectPriority = .medium
    var references: [ReferenceImage] = []
}

struct ReferenceImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

enum TimeEstimate: String, CaseIterable {
    case quickSketch = "Quick Sketch"
    case singleSession = "Single Session"
    case lessThanWeek = "Less Than a Week"
    case oneToTwoWeeks = "1-2 Weeks"
    case moreThanTwoWeeks = "More Than 2 Weeks"
    
    var description: String {
        return rawValue
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