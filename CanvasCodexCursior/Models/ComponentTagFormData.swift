import Foundation

struct ComponentTagFormData {
    var type: ComponentType = .subject
    var name: String = ""
    var notes: String = ""
    var processSteps: String = ""
    var rating1: Int = 0  // Satisfaction/Effectiveness
    var rating2: Int = 0  // Complexity/Difficulty
    var locationX: Double = 0.0
    var locationY: Double = 0.0
    
    var isValid: Bool {
        !name.isEmpty
    }
    
    var rating1Label: String {
        switch type {
        case .subject:
            return "Satisfaction with Result"
        case .process:
            return "Effectiveness"
        }
    }
    
    var rating2Label: String {
        switch type {
        case .subject:
            return "Complexity Level"
        case .process:
            return "Difficulty"
        }
    }
} 