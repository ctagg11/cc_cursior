import Foundation

enum DimensionType {
    case twoDimensional
    case threeDimensional
}

enum DimensionUnit: String, CaseIterable {
    case inches = "in"
    case centimeters = "cm"
    case pixels = "px"
} 