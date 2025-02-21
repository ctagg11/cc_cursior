import SwiftUI
import UIKit

// MARK: - Color Models
struct PaletteColor: Identifiable, Equatable {
    let id = UUID()
    let color: Color
    let hex: String
    let name: String
}

class ColorPaletteModel: ObservableObject {
    @Published var generatedColors: [PaletteColor] = []
    
    // MARK: - Color Harmony Generation
    func generateHarmony(from baseColor: Color, type: HarmonyType, count: Int) -> [PaletteColor] {
        var colors: [PaletteColor] = []
        let hsb = baseColor.hsbaComponents
        
        switch type {
        case .complementary:
            colors.append(PaletteColor(color: baseColor, hex: baseColor.hexString, name: "Base"))
            let complement = Color(hue: (hsb.hue + 0.5).truncatingRemainder(dividingBy: 1.0),
                                 saturation: hsb.saturation,
                                 brightness: hsb.brightness,
                                 opacity: hsb.alpha)
            colors.append(PaletteColor(color: complement, hex: complement.hexString, name: "Complement"))
            
        case .analogous:
            let angles: [Double] = [-30, 0, 30].map { $0 / 360.0 }
            for angle in angles {
                let color = Color(hue: (hsb.hue + angle).truncatingRemainder(dividingBy: 1.0),
                                saturation: hsb.saturation,
                                brightness: hsb.brightness,
                                opacity: hsb.alpha)
                colors.append(PaletteColor(color: color, hex: color.hexString, name: "Analogous"))
            }
            
        case .triadic:
            let angles: [Double] = [0, 120, 240].map { $0 / 360.0 }
            for angle in angles {
                let color = Color(hue: (hsb.hue + angle).truncatingRemainder(dividingBy: 1.0),
                                saturation: hsb.saturation,
                                brightness: hsb.brightness,
                                opacity: hsb.alpha)
                colors.append(PaletteColor(color: color, hex: color.hexString, name: "Triadic"))
            }
            
        case .splitComplementary:
            colors.append(PaletteColor(color: baseColor, hex: baseColor.hexString, name: "Base"))
            let angles: [Double] = [150, 210].map { $0 / 360.0 }
            for angle in angles {
                let color = Color(hue: (hsb.hue + angle).truncatingRemainder(dividingBy: 1.0),
                                saturation: hsb.saturation,
                                brightness: hsb.brightness,
                                opacity: hsb.alpha)
                colors.append(PaletteColor(color: color, hex: color.hexString, name: "Split"))
            }
        }
        
        return colors
    }
    
    // MARK: - Image Color Extraction
    func extractColors(from image: UIImage, isDominant: Bool, count: Int) -> [PaletteColor] {
        // TODO: Implement color extraction from image
        // For now, return placeholder colors
        return []
    }
    
    // MARK: - Description-based Generation
    func generateFromDescription(_ description: String, moods: Set<Mood>, count: Int) -> [PaletteColor] {
        // TODO: Implement AI-based color generation from description
        // For now, return placeholder colors
        return []
    }
    
    // MARK: - Color Manipulation
    func generateShades(for color: Color, count: Int) -> [PaletteColor] {
        var shades: [PaletteColor] = []
        let hsb = color.hsbaComponents
        
        for i in 0..<count {
            let brightness = Double(i) / Double(count - 1)
            let shade = Color(hue: hsb.hue,
                            saturation: hsb.saturation,
                            brightness: brightness,
                            opacity: hsb.alpha)
            shades.append(PaletteColor(color: shade, hex: shade.hexString, name: "Shade \(i + 1)"))
        }
        
        return shades
    }
    
    func generateNeutrals(count: Int) -> [PaletteColor] {
        var neutrals: [PaletteColor] = []
        
        for i in 0..<count {
            let value = Double(i) / Double(count - 1)
            let neutral = Color(white: value)
            neutrals.append(PaletteColor(color: neutral, hex: neutral.hexString, name: "Neutral \(i + 1)"))
        }
        
        return neutrals
    }
}

// MARK: - Color Extensions
extension Color {
    var hexString: String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(Float(r * 255)),
                     lroundf(Float(g * 255)),
                     lroundf(Float(b * 255)))
    }
    
    var hsbaComponents: (hue: Double, saturation: Double, brightness: Double, alpha: Double) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return (Double(hue), Double(saturation), Double(brightness), Double(alpha))
    }
} 