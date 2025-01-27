import SwiftUI

struct ArtworkFormData {
    var name = ""
    var medium = ""
    var galleryId = ""
    var dimensionType: DimensionType = .twoDimensional
    var width: Double = 0
    var height: Double = 0
    var depth: Double = 0
    var units: DimensionUnit = .inches
    var startDate: Date = Date()
    var completionDate: Date = Date()
    var isPublic: Bool = false
    
    var hasDimensions: Bool {
        width > 0 && height > 0 && (dimensionType == .twoDimensional || depth > 0)
    }
    
    var hasDateRange: Bool {
        !Calendar.current.isDate(startDate, inSameDayAs: completionDate)
    }
    
    var dimensionsDisplay: String {
        let w = validateDimension(width)
        let h = validateDimension(height)
        let d = validateDimension(depth)
        
        if dimensionType == .twoDimensional {
            return String(format: "%.1f × %.1f %@", w, h, units.rawValue)
        } else {
            return String(format: "%.1f × %.1f × %.1f %@", w, h, d, units.rawValue)
        }
    }
    
    var dateRangeDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        if Calendar.current.isDate(startDate, inSameDayAs: completionDate) {
            return formatter.string(from: completionDate)
        } else {
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: completionDate))"
        }
    }
    
    var isValid: Bool {
        !name.isEmpty && !galleryId.isEmpty
    }
    
    private func validateDimension(_ value: Double) -> Double {
        if value.isNaN || value < 0 {
            return 0
        }
        return value
    }
} 