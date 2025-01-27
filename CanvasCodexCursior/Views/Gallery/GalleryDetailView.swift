import SwiftUI

struct GalleryDetailView: View {
    let gallery: GalleryEntity
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingDeleteConfirmation = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                if let artworks = gallery.artworks?.allObjects as? [ArtworkEntity] {
                    ForEach(artworks) { artwork in
                        NavigationLink(destination: ArtworkDetailView(artwork: artwork)) {
                            ArtworkThumbnail(artwork: artwork)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(gallery.name ?? "")
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