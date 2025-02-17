import SwiftUI
import UniformTypeIdentifiers

struct GalleryDetailView: View {
    let gallery: GalleryEntity
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingDeleteConfirmation = false
    @State private var isDragging = false
    @GestureState private var isLongPressed = false
    
    // Calculate item size based on screen width minus padding and spacing
    private var gridItemSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let totalPadding: CGFloat = 32  // 16 points padding on each side
        let totalSpacing: CGFloat = 32   // 16 points spacing between items
        return (screenWidth - totalPadding - totalSpacing) / 3
    }
    
    // Grid layout with fixed size items
    private var columns: [GridItem] {
        [
            GridItem(.fixed(gridItemSize), spacing: 16),
            GridItem(.fixed(gridItemSize), spacing: 16),
            GridItem(.fixed(gridItemSize), spacing: 16)
        ]
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                if let artworks = (gallery.artworks?.allObjects as? [ArtworkEntity])?
                    .sorted(by: { $0.sortOrder < $1.sortOrder }) {
                    ForEach(artworks) { artwork in
                        artworkView(artwork: artwork, allArtworks: artworks)
                            .scaleEffect(isLongPressed ? 0.95 : 1.0)
                            .animation(.spring(duration: 0.3), value: isLongPressed)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .navigationTitle(gallery.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .alert("Delete Gallery?", isPresented: $showingDeleteConfirmation) {
            deleteAlertButtons
        } message: {
            Text("This will only remove the gallery, not the artwork within it.")
        }
    }
    
    private func artworkView(artwork: ArtworkEntity, allArtworks: [ArtworkEntity]) -> some View {
        NavigationLink(destination: ArtworkDetailView(artwork: artwork)) {
            ArtworkThumbnail(artwork: artwork)
                .frame(width: gridItemSize, height: gridItemSize)
                .clipped()
        }
        .gesture(
            LongPressGesture(minimumDuration: 0.5)
                .updating($isLongPressed) { currentState, gestureState, _ in
                    gestureState = currentState
                    if currentState {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
                }
        )
        .draggable(TransferableID(id: artwork.id ?? UUID()))
        .onDrop(of: [UTType.plainText], delegate: DropViewDelegate(
            item: artwork,
            items: allArtworks,
            viewContext: viewContext,
            onDragStarted: {
                withAnimation {
                    isDragging = true
                }
            },
            onDragEnded: {
                withAnimation {
                    isDragging = false
                }
            }
        ))
    }
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .destructiveAction) {
            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .frame(width: 44, height: 44)
            }
        }
    }
    
    private var deleteAlertButtons: some View {
        Group {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteGallery()
            }
        }
    }
    
    private func deleteGallery() {
        viewContext.delete(gallery)
        try? viewContext.save()
        dismiss()
    }
} 