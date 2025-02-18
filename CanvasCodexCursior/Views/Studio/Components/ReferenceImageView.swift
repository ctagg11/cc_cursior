import SwiftUI

struct ReferenceImageView: View {
    let reference: ReferenceEntity
    @State private var showingFullscreen = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let fileName = reference.imageFileName,
               let image = ImageManager.shared.loadImage(fileName: fileName, category: .reference) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                        showingFullscreen = true
                    }
                    .fullScreenCover(isPresented: $showingFullscreen) {
                        ZoomableImageView(image: Image(uiImage: image))
                    }
            }
            
            if let title = reference.title {
                Text(title)
                    .font(.caption)
                    .lineLimit(2)
            }
            
            if let notes = reference.notes {
                Text(notes)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

