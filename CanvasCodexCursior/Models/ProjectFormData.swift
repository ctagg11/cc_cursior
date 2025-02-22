import Foundation
import UIKit

struct ProjectFormData {
    var name: String = ""
    var medium: String = ""
    var startDate: Date = Date()
    var inspiration: String = ""
    var skills: String = ""
    var timeEstimate: TimeEstimate = .singleSession
    var difficultyLevel: DifficultyLevel = .moderate
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

enum DifficultyLevel: String, CaseIterable {
    case beginner = "Beginner Friendly"
    case moderate = "Moderate Challenge"
    case advanced = "Advanced Technique"
    case experimental = "Experimental/Unknown"
    
    var description: String {
        return rawValue
    }
} 