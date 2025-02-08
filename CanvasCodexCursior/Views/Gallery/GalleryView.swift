import SwiftUI

struct GalleryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GalleryEntity.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \GalleryEntity.name, ascending: true)
        ],
        animation: .default
    ) private var galleries: FetchedResults<GalleryEntity>
    
    @State private var isEditingOrder = false
    @StateObject private var viewModel = ArtworkViewModel()
    @State private var showingGalleryCreation = false
    @State private var showingDeleteAlert = false
    @State private var artworkToDelete: ArtworkEntity?
    
    var body: some View {
        NavigationStack {
            Group {
                if galleries.isEmpty {
                    ContentUnavailableView(
                        "No Galleries",
                        systemImage: "photo.stack",
                        description: Text("Create a gallery and upload your art to display your work")
                    )
                    .padding()
                } else if isEditingOrder {
                    reorderList
                } else {
                    galleryGrid
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Galleries")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            isEditingOrder.toggle()
                        }
                    } label: {
                        Image(systemName: isEditingOrder ? "checkmark" : "list.bullet")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingGalleryCreation = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingGalleryCreation) {
                CreateGallerySheet()
            }
        }
        .onAppear {
            viewModel.loadGalleries()  // Refresh galleries when view appears
        }
    }
    
    private var reorderList: some View {
        List {
            ForEach(galleries) { gallery in
                HStack {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(.secondary)
                    Text(gallery.name ?? "")
                        .font(.headline)
                    Spacer()
                    Text("\(gallery.artworks?.count ?? 0) artworks")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .onMove { source, destination in
                // Create haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                // Update Core Data
                var galleries = galleries.map { $0 }
                galleries.move(fromOffsets: source, toOffset: destination)
                
                // Update sort order
                for (index, gallery) in galleries.enumerated() {
                    gallery.sortOrder = Int32(index)
                }
                
                try? viewContext.save()
            }
        }
        .environment(\.editMode, .constant(.active))
    }
    
    private var galleryGrid: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(galleries) { gallery in
                    VStack(alignment: .leading, spacing: 12) {
                        NavigationLink(destination: GalleryDetailView(gallery: gallery)) {
                            HStack {
                                Text(gallery.name ?? "")
                                    .font(.title2.bold())
                                
                                Spacer()
                                
                                Text("\(gallery.artworks?.count ?? 0)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.trailing, 4)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .foregroundStyle(.primary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 12) {
                                if let artworks = gallery.artworks?.allObjects as? [ArtworkEntity] {
                                    ForEach(artworks) { artwork in
                                        NavigationLink(destination: ArtworkDetailView(artwork: artwork)) {
                                            ArtworkThumbnail(artwork: artwork)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

struct ArtworkThumbnail: View {
    let artwork: ArtworkEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let fileName = artwork.imageFileName,
               let image = ImageManager.shared.loadImage(fileName: fileName, category: .artwork) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 250, maxHeight: 250)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 250, height: 250)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            }
            
            Text(artwork.name ?? "")
                .font(.subheadline)
                .lineLimit(2)
                .foregroundStyle(.primary)
        }
        .frame(width: 250)
    }
}

struct EmptyGalleryView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            
            Text("No artwork yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(width: 250, height: 300)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}