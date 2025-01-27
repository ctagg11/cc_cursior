import SwiftUI

struct ReferenceCard: View {
    let reference: ReferenceEntity
    
    var body: some View {
        VStack(alignment: .leading) {
            if let fileName = reference.imageFileName,
               let image = ImageManager.shared.loadImage(fileName: fileName, category: .reference) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            if let title = reference.title {
                Text(title)
                    .font(.caption)
                    .lineLimit(2)
            }
        }
    }
} 