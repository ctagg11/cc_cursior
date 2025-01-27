import SwiftUI

struct IdentifiableImage: Identifiable, Equatable {
    let id = UUID()
    let image: UIImage
    
    static func == (lhs: IdentifiableImage, rhs: IdentifiableImage) -> Bool {
        lhs.id == rhs.id
    }
} 