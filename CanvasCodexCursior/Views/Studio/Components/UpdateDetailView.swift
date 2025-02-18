import SwiftUI

struct UpdateDetailView: View {
    let update: ProjectUpdateEntity
    @State private var showingFullscreen = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Main Image
            if let fileName = update.imageFileName,
               let image = ImageManager.shared.loadImage(fileName: fileName, category: .projectUpdate) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture {
                        showingFullscreen = true
                    }
                    .fullScreenCover(isPresented: $showingFullscreen) {
                        ZoomableImageView(image: Image(uiImage: image))
                    }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Date and Title
                HStack {
                    Text(update.date?.formatted(date: .abbreviated, time: .shortened) ?? "")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if update.isPublic {
                        Image(systemName: "globe")
                            .foregroundStyle(.secondary)
                    }
                }
                
                if let changes = update.changes, !changes.isEmpty {
                    Text(changes)
                }
                
                if let todoNotes = update.todoNotes, !todoNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Todo:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(todoNotes)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
} 