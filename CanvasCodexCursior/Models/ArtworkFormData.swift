import SwiftUI

struct ArtworkFormData {
    var name: String = ""
    var medium: String = ""
    var galleryId: String = ""
    var dimensionType: DimensionType = .twoDimensional
    var width: Double = 0
    var height: Double = 0
    var depth: Double = 0
    var units: DimensionUnit = .inches
    var startDate: Date = Date()
    var completionDate: Date = Date()
    var isPublic: Bool = false
    var referenceImageData: Data?
    
    var hasDimensions: Bool {
        width > 0 && height > 0 && (dimensionType == .twoDimensional || depth > 0)
    }
    
    var hasDateRange: Bool {
        !Calendar.current.isDate(startDate, inSameDayAs: completionDate)
    }
    
    var dimensions: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        let w = formatter.string(from: NSNumber(value: width)) ?? "0"
        let h = formatter.string(from: NSNumber(value: height)) ?? "0"
        
        if dimensionType == .twoDimensional {
            return "\(w) × \(h) \(units.rawValue)"
        } else {
            let d = formatter.string(from: NSNumber(value: depth)) ?? "0"
            return "\(w) × \(h) × \(d) \(units.rawValue)"
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
        !name.isEmpty && 
        !galleryId.isEmpty && 
        startDate <= completionDate
    }
    
    private func validateDimension(_ value: Double) -> Double {
        if value.isNaN || value < 0 {
            return 0
        }
        return value
    }
}
