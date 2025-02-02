import SwiftUI

// MARK: - Models
struct CodableColor: Codable {
    let hex: String
    
    init(_ color: Color) {
        // Store the actual color's hex value
        if let hexString = color.description.components(separatedBy: "hex:").last?.trimmingCharacters(in: .whitespaces) {
            self.hex = hexString
        } else {
            self.hex = "#FFFFFF" // Fallback to white only if conversion fails
        }
    }
    
    init(hex: String) {
        self.hex = hex
    }
    
    var color: Color {
        Color(hex: hex)
    }
}

struct PaintColor: Identifiable, Codable {
    let id: UUID
    let name: String
    let brand: PaintBrand
    private let codableColor: CodableColor
    let type: PaintType
    let series: String?
    let code: String
    let isCustom: Bool
    let lightfastness: Lightfastness?
    let opacity: PaintOpacity?
    
    var color: Color {
        codableColor.color
    }
    
    init(name: String, 
         brand: PaintBrand, 
         color: Color, 
         type: PaintType, 
         series: String? = nil, 
         code: String = "", 
         isCustom: Bool = false,
         lightfastness: Lightfastness? = nil, 
         opacity: PaintOpacity? = nil) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.codableColor = CodableColor(color)
        self.type = type
        self.series = series
        self.code = code
        self.isCustom = isCustom
        self.lightfastness = lightfastness
        self.opacity = opacity
    }
}

enum PaintBrand: String, Codable, CaseIterable {
    case winsorNewton = "Winsor & Newton"
    case goldenAcrylics = "Golden"
    case danielSmith = "Daniel Smith"
    case liquitex = "Liquitex"
    case gamblin = "Gamblin"
    case holbein = "Holbein"
    case schmincke = "Schmincke"
    case mgraham = "M. Graham"
    case sennelier = "Sennelier"
    case amsterdamAcrylic = "Amsterdam"
    case custom = "Custom Colors"
    
    var types: [PaintType] {
        switch self {
        case .winsorNewton:
            return [.oil, .watercolor, .acrylic]
        case .goldenAcrylics, .liquitex, .amsterdamAcrylic:
            return [.acrylic]
        case .danielSmith, .holbein, .schmincke:
            return [.watercolor]
        case .gamblin, .mgraham:
            return [.oil]
        case .sennelier:
            return [.oil, .watercolor]
        case .custom:
            return [.oil, .watercolor, .acrylic]
        }
    }
}

enum PaintType: String, Codable, CaseIterable {
    case watercolor
    case oil
    case acrylic
}

enum Lightfastness: String, Codable {
    case excellent = "Excellent (I)"
    case veryGood = "Very Good (II)"
    case fair = "Fair (III)"
    case poor = "Poor (IV)"
}

enum PaintOpacity: String, Codable {
    case transparent
    case semitransparent
    case semiopaque
    case opaque
}

// MARK: - Database
class PaintDatabase {
    static let shared = PaintDatabase()
    private var customColors: [PaintColor] = []
    
    // Load from local JSON in a real implementation
    private var standardColors: [PaintColor] = [
        // Winsor & Newton Artists' Oil Colours - Verified from W&N website
        PaintColor(name: "Titanium White", brand: .winsorNewton, color: Color(hex: "#FFFFFF"), type: .oil, series: "1", code: "644"),
        PaintColor(name: "Cadmium Yellow Light", brand: .winsorNewton, color: Color(hex: "#FFF44F"), type: .oil, series: "4", code: "086"),
        PaintColor(name: "Cadmium Yellow", brand: .winsorNewton, color: Color(hex: "#FFB81C"), type: .oil, series: "4", code: "108"),
        PaintColor(name: "French Ultramarine", brand: .winsorNewton, color: Color(hex: "#1B365D"), type: .oil, series: "2", code: "263"),
        PaintColor(name: "Cobalt Blue", brand: .winsorNewton, color: Color(hex: "#0047AB"), type: .oil, series: "4", code: "178"),
        PaintColor(name: "Cerulean Blue", brand: .winsorNewton, color: Color(hex: "#2A52BE"), type: .oil, series: "4", code: "137"),
        PaintColor(name: "Viridian", brand: .winsorNewton, color: Color(hex: "#007F66"), type: .oil, series: "4", code: "692"),
        PaintColor(name: "Permanent Alizarin Crimson", brand: .winsorNewton, color: Color(hex: "#E32636"), type: .oil, series: "3", code: "468"),
        PaintColor(name: "Burnt Sienna", brand: .winsorNewton, color: Color(hex: "#8A3324"), type: .oil, series: "1", code: "074"),
        PaintColor(name: "Yellow Ochre", brand: .winsorNewton, color: Color(hex: "#CC7722"), type: .oil, series: "1", code: "744"),
        PaintColor(name: "Raw Umber", brand: .winsorNewton, color: Color(hex: "#826644"), type: .oil, series: "1", code: "554"),
        PaintColor(name: "Ivory Black", brand: .winsorNewton, color: Color(hex: "#1B1B1B"), type: .oil, series: "1", code: "331"),
        
        // Winsor & Newton Watercolors
        PaintColor(name: "Alizarin Crimson", brand: .winsorNewton, color: Color(hex: "#E32636"), type: .watercolor, series: "1", code: "004", lightfastness: .fair, opacity: .transparent),
        PaintColor(name: "Cerulean Blue", brand: .winsorNewton, color: Color(hex: "#2A52BE"), type: .watercolor, series: "3", code: "137", lightfastness: .excellent, opacity: .semiopaque),
        PaintColor(name: "Winsor Yellow", brand: .winsorNewton, color: Color(hex: "#FFC30B"), type: .watercolor, series: "1", code: "730", lightfastness: .excellent, opacity: .transparent),
        PaintColor(name: "Burnt Umber", brand: .winsorNewton, color: Color(hex: "#8B4513"), type: .watercolor, series: "1", code: "076", lightfastness: .excellent, opacity: .semiopaque),
        PaintColor(name: "Sap Green", brand: .winsorNewton, color: Color(hex: "#507D2A"), type: .watercolor, series: "1", code: "599", lightfastness: .veryGood, opacity: .transparent),
        PaintColor(name: "Payne's Gray", brand: .winsorNewton, color: Color(hex: "#40404F"), type: .watercolor, series: "1", code: "465", lightfastness: .excellent, opacity: .semiopaque),
        PaintColor(name: "Permanent Rose", brand: .winsorNewton, color: Color(hex: "#FF033E"), type: .watercolor, series: "3", code: "502", lightfastness: .excellent, opacity: .transparent),
        PaintColor(name: "Indigo", brand: .winsorNewton, color: Color(hex: "#000F89"), type: .watercolor, series: "1", code: "322", lightfastness: .excellent, opacity: .transparent),
        PaintColor(name: "Cobalt Turquoise", brand: .winsorNewton, color: Color(hex: "#40E0D0"), type: .watercolor, series: "4", code: "191", lightfastness: .excellent, opacity: .semiopaque),
        PaintColor(name: "Quinacridone Gold", brand: .winsorNewton, color: Color(hex: "#C5832B"), type: .watercolor, series: "2", code: "547", lightfastness: .excellent, opacity: .transparent),
        PaintColor(name: "Perylene Maroon", brand: .winsorNewton, color: Color(hex: "#8B0000"), type: .watercolor, series: "2", code: "507", lightfastness: .excellent, opacity: .transparent),
        PaintColor(name: "Neutral Tint", brand: .winsorNewton, color: Color(hex: "#736664"), type: .watercolor, series: "1", code: "425", lightfastness: .excellent, opacity: .transparent),

        // Winsor & Newton Professional Acrylics
        PaintColor(name: "Mars Black", brand: .winsorNewton, color: Color(hex: "#232323"), type: .acrylic, series: "1", code: "386", lightfastness: .excellent, opacity: .opaque),
        PaintColor(name: "Phthalo Blue (Green Shade)", brand: .winsorNewton, color: Color(hex: "#000F89"), type: .acrylic, series: "2", code: "515", lightfastness: .excellent, opacity: .transparent),
        PaintColor(name: "Cadmium Yellow Medium", brand: .winsorNewton, color: Color(hex: "#FFB200"), type: .acrylic, series: "4", code: "111", lightfastness: .excellent, opacity: .opaque),
        PaintColor(name: "Burnt Sienna", brand: .winsorNewton, color: Color(hex: "#8A3324"), type: .acrylic, series: "1", code: "074", lightfastness: .excellent, opacity: .semitransparent),
        PaintColor(name: "Yellow Ochre", brand: .winsorNewton, color: Color(hex: "#CC7722"), type: .acrylic, series: "1", code: "744", lightfastness: .excellent, opacity: .semiopaque),

        // Golden Acrylics
        PaintColor(name: "Carbon Black", brand: .goldenAcrylics, color: Color(hex: "#000000"), type: .acrylic, series: "1", code: "8040", lightfastness: .excellent, opacity: .opaque),
        PaintColor(name: "Quinacridone Magenta", brand: .goldenAcrylics, color: Color(hex: "#8E4585"), type: .acrylic, series: "6", code: "8320", lightfastness: .excellent, opacity: .transparent),
        PaintColor(name: "Phthalo Blue (GS)", brand: .goldenAcrylics, color: Color(hex: "#0C3B7B"), type: .acrylic, series: "4", code: "8300", lightfastness: .excellent, opacity: .transparent),
        
        // Daniel Smith Watercolors
        PaintColor(name: "Phthalo Blue GS", brand: .danielSmith, color: Color(hex: "#0093AF"), type: .watercolor, series: "1", code: "284", lightfastness: .excellent, opacity: .transparent),
        PaintColor(name: "Lunar Black", brand: .danielSmith, color: Color(hex: "#1C1C1C"), type: .watercolor, series: "1", code: "211", lightfastness: .excellent, opacity: .semiopaque),
        
        // Gamblin Oils
        PaintColor(name: "Titanium White", brand: .gamblin, color: Color(hex: "#FFFFFF"), type: .oil, series: "1", code: "1980", lightfastness: .excellent, opacity: .opaque),
        PaintColor(name: "Cadmium Yellow Light", brand: .gamblin, color: Color(hex: "#FFF200"), type: .oil, series: "4", code: "1250", lightfastness: .excellent, opacity: .opaque),
        PaintColor(name: "Ultramarine Blue", brand: .gamblin, color: Color(hex: "#1B1B7F"), type: .oil, series: "2", code: "1960", lightfastness: .excellent, opacity: .transparent),
        
        // Holbein Watercolors
        PaintColor(name: "Opera", brand: .holbein, color: Color(hex: "#FF0080"), type: .watercolor, series: "2", code: "W137", lightfastness: .poor, opacity: .transparent),
        PaintColor(name: "Mineral Violet", brand: .holbein, color: Color(hex: "#8B72BE"), type: .watercolor, series: "2", code: "W139", lightfastness: .excellent, opacity: .semitransparent),
        
        // Schmincke Watercolors
        PaintColor(name: "Helio Turquoise", brand: .schmincke, color: Color(hex: "#3BBCD0"), type: .watercolor, series: "2", code: "509", lightfastness: .excellent, opacity: .transparent),
        PaintColor(name: "Purple Magenta", brand: .schmincke, color: Color(hex: "#9F1F6A"), type: .watercolor, series: "2", code: "367", lightfastness: .excellent, opacity: .transparent),
        
        // M. Graham Oils
        PaintColor(name: "Ultramarine Blue", brand: .mgraham, color: Color(hex: "#1C1C7C"), type: .oil, series: "2", code: "11-510", lightfastness: .excellent, opacity: .transparent),
        
        // Liquitex Acrylics
        PaintColor(name: "Titanium White", brand: .liquitex, color: Color(hex: "#FFFFFF"), type: .acrylic, series: "1", code: "432", lightfastness: .excellent, opacity: .opaque),
        PaintColor(name: "Phthalocyanine Blue", brand: .liquitex, color: Color(hex: "#0F4C81"), type: .acrylic, series: "1", code: "316", lightfastness: .excellent, opacity: .transparent),
        PaintColor(name: "Quinacridone Crimson", brand: .liquitex, color: Color(hex: "#C41E3A"), type: .acrylic, series: "2", code: "110", lightfastness: .excellent, opacity: .transparent),
        
        // Amsterdam Acrylics
        PaintColor(name: "Primary Yellow", brand: .amsterdamAcrylic, color: Color(hex: "#FCD116"), type: .acrylic, series: "1", code: "275", lightfastness: .excellent, opacity: .semiopaque),
        PaintColor(name: "Primary Cyan", brand: .amsterdamAcrylic, color: Color(hex: "#0077BB"), type: .acrylic, series: "1", code: "572", lightfastness: .excellent, opacity: .transparent)
    ]
    
    func getColors(for brand: PaintBrand, type: PaintType) -> [PaintColor] {
        if brand == .custom {
            return customColors.filter { $0.type == type }
        }
        return standardColors.filter { $0.brand == brand && $0.type == type }
    }
    
    func addCustomColor(_ color: PaintColor) {
        customColors.append(color)
        saveCustomColors()
    }
    
    private func saveCustomColors() {
        // Save to UserDefaults or local storage
    }
}

// MARK: - Color Utilities
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 