import SwiftUI

struct ArtworkDetailView: View {
    let artwork: ArtworkEntity
    @State private var image: UIImage?
    @State private var showingDeleteConfirmation = false
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingFullscreen = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Artwork Image
                if let fileName = artwork.imageFileName,
                   let image = ImageManager.shared.loadImage(fileName: fileName, category: .artwork) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            showingFullscreen = true
                        }
                        .fullScreenCover(isPresented: $showingFullscreen) {
                            ZoomableImageView(image: image)
                        }
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 300)
                        .overlay {
                            ProgressView()
                        }
                }
                
                // Artwork Information
                VStack(spacing: 20) {
                    // Basic Info Section
                    InfoSection(title: "Details") {
                        InfoRow(label: "Medium", value: artwork.medium ?? "Not specified")
                        if let dimensions = artwork.dimensions {
                            InfoRow(label: "Dimensions", value: dimensions)
                        }
                        if let startDate = artwork.startDate {
                            InfoRow(label: "Started", value: startDate.formatted(date: .abbreviated, time: .omitted))
                        }
                        if let completionDate = artwork.completionDate {
                            InfoRow(label: "Completed", value: completionDate.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                    
                    // Galleries Section
                    if let galleries = artwork.galleries?.allObjects as? [GalleryEntity], !galleries.isEmpty {
                        InfoSection(title: "Galleries") {
                            ForEach(galleries) { gallery in
                                NavigationLink {
                                    GalleryDetailView(gallery: gallery)
                                } label: {
                                    HStack {
                                        Text(gallery.name ?? "")
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Notes Section
                    if let notes = artwork.inspirationNotes, !notes.isEmpty {
                        InfoSection(title: "Inspiration & Notes") {
                            Text(notes)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // References Section
                    if let references = artwork.references?.allObjects as? [ReferenceEntity], !references.isEmpty {
                        InfoSection(title: "References") {
                            ForEach(references) { reference in
                                ReferenceRow(reference: reference)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(artwork.name ?? "Artwork")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .frame(width: 44, height: 44)
                }
            }
        }
        .alert("Delete Artwork?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteArtwork()
            }
        } message: {
            Text("This will permanently delete this artwork and its associated data.")
        }
        .onAppear {
            if let fileName = artwork.imageFileName {
                image = ImageManager.shared.loadImage(fileName: fileName, category: .artwork)
            }
        }
    }
    
    private func deleteArtwork() {
        // Delete the image file
        if let fileName = artwork.imageFileName {
            ImageManager.shared.deleteImage(fileName: fileName, category: .artwork)
        }
        
        // Delete the CoreData entity
        viewContext.delete(artwork)
        try? viewContext.save()
        dismiss()
    }
}

// MARK: - Supporting Views

struct InfoSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.subheadline)
    }
}

struct ReferenceRow: View {
    let reference: ReferenceEntity
    @State private var image: UIImage?
    
    var body: some View {
        HStack(spacing: 12) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reference.title ?? "")
                    .font(.headline)
                
                if let notes = reference.notes {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .onAppear {
            if let fileName = reference.imageFileName {
                image = ImageManager.shared.loadImage(fileName: fileName, category: .reference)
            }
        }
    }
} 