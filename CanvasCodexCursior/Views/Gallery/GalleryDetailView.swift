import SwiftUI
import CoreData

public struct GalleryDetailView: View {
    let gallery: GalleryEntity
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    public init(gallery: GalleryEntity) {
        self.gallery = gallery
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Gallery Info Header
                VStack(spacing: 8) {
                    if let artworks = gallery.artworks?.allObjects as? [ArtworkEntity], !artworks.isEmpty,
                       let firstArtwork = artworks.first,
                       let fileName = firstArtwork.imageFileName,
                       let uiImage = ImageManager.shared.loadImage(fileName: fileName, category: .artwork) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(alignment: .bottomLeading) {
                                Text(gallery.name ?? "Gallery")
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [.black.opacity(0.7), .clear],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                            }
                    } else {
                        Text(gallery.name ?? "Gallery")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                    
                    Text("\(gallery.artworks?.count ?? 0) artworks")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
                
                // Artwork Grid
                if let artworks = (gallery.artworks?.allObjects as? [ArtworkEntity])?
                    .sorted(by: { $0.sortOrder < $1.sortOrder }) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(artworks) { artwork in
                            NavigationLink(destination: ArtworkDetailView(artwork: artwork)) {
                                if let fileName = artwork.imageFileName,
                                   let uiImage = ImageManager.shared.loadImage(fileName: fileName, category: .artwork) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 100, height: 100)
                                        .overlay {
                                            Image(systemName: "photo")
                                                .foregroundStyle(.secondary)
                                        }
                                }
                            }
                        }
                    }
                    .padding()
                } else {
                    ContentUnavailableView(
                        "No Artwork",
                        systemImage: "photo.stack",
                        description: Text("Add some artwork to this gallery to get started")
                    )
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Delete Gallery?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteGallery()
            }
        } message: {
            Text("This will only remove the gallery, not the artwork within it.")
        }
    }
    
    private func deleteGallery() {
        viewContext.delete(gallery)
        try? viewContext.save()
        dismiss()
    }
} 