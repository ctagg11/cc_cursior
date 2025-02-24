import SwiftUI
import CoreData
import UIKit

public struct ArtworkDetailView: View {
    let artwork: ArtworkEntity
    @State private var showingDeleteConfirmation = false
    @State private var showingGallerySheet = false
    @State private var showingCreateGallery = false
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingFullscreen = false
    @State private var showingReferenceFullscreen = false
    
    // Fetch request for available galleries
    @FetchRequest(
        entity: GalleryEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GalleryEntity.name, ascending: true)
        ]
    ) private var galleries: FetchedResults<GalleryEntity>
    
    public init(artwork: ArtworkEntity) {
        self.artwork = artwork
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(artwork.name ?? "Untitled")
                    .font(.title)
                    .fontWeight(.bold)
                    .italic()
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                
                if let completionDate = artwork.completionDate {
                    Text("(\(completionDate.formatted(.dateTime.month())) \(completionDate.formatted(.dateTime.year())))")
                        .font(.title)
                        .fontWeight(.regular)
                        .italic()
                }
            }
            
            if let medium = artwork.medium {
                Text(medium)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            if let notes = artwork.inspirationNotes, !notes.isEmpty {
                Text(notes)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Artwork Image
                if let fileName = artwork.imageFileName,
                   let uiImage = ImageManager.shared.loadImage(fileName: fileName, category: .artwork) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            showingFullscreen = true
                        }
                        .fullScreenCover(isPresented: $showingFullscreen) {
                            ZoomableImageView(image: Image(uiImage: uiImage))
                        }
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 300)
                        .overlay {
                            ProgressView()
                        }
                }
                
                // Gallery-style Label Section
                titleSection
                
                // Detailed Information
                VStack(spacing: 20) {
                    // Details Section
                    InfoSection(title: "Details") {
                        if let dimensions = artwork.dimensions {
                            InfoRow(label: "Dimensions", value: dimensions)
                        }
                        if let startDate = artwork.startDate {
                            InfoRow(label: "Started", value: startDate.formatted(date: .abbreviated, time: .omitted))
                        }
                        InfoRow(label: "Completed", value: artwork.completionDate?.formatted(date: .abbreviated, time: .omitted) ?? "")
                    }
                    
                    // Reference Image Section
                    if let referenceImageData = artwork.referenceImageData,
                       let referenceImage = UIImage(data: referenceImageData) {
                        InfoSection(title: "Reference Image") {
                            Image(uiImage: referenceImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    showingReferenceFullscreen = true
                                }
                        }
                        .fullScreenCover(isPresented: $showingReferenceFullscreen) {
                            ZoomableImageView(image: Image(uiImage: referenceImage))
                        }
                    }
                    
                    // Galleries Section
                    if let artworkGalleries = artwork.galleries?.allObjects as? [GalleryEntity],
                       !artworkGalleries.isEmpty {
                        InfoSection(title: "Galleries") {
                            VStack(spacing: 12) {
                                ForEach(artworkGalleries.sorted(by: { $0.name ?? "" < $1.name ?? "" })) { gallery in
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
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Menu {
                        if galleries.isEmpty {
                            Button {
                                showingCreateGallery = true
                            } label: {
                                Label("Create New Gallery", systemImage: "folder.badge.plus")
                            }
                        } else {
                            Button {
                                showingGallerySheet = true
                            } label: {
                                Label("Add to Gallery", systemImage: "folder.badge.plus")
                            }
                            
                            Button {
                                showingCreateGallery = true
                            } label: {
                                Label("Create New Gallery", systemImage: "folder.badge.plus")
                            }
                        }
                    } label: {
                        Label("Add to Gallery", systemImage: "folder")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Artwork", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
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
        .sheet(isPresented: $showingCreateGallery) {
            CreateGallerySheet { gallery in
                addToGallery(gallery)
            }
        }
        .sheet(isPresented: $showingGallerySheet) {
            NavigationStack {
                List {
                    ForEach(galleries) { gallery in
                        let isInGallery = (artwork.galleries?.contains(gallery) ?? false)
                        Button {
                            if isInGallery {
                                removeFromGallery(gallery)
                            } else {
                                addToGallery(gallery)
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(gallery.name ?? "")
                                        .foregroundStyle(.primary)
                                    Text("\(gallery.artworks?.count ?? 0) artworks")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if isInGallery {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Choose Gallery")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") {
                            showingGallerySheet = false
                        }
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingGallerySheet = false
                            showingCreateGallery = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
    }
    
    private func addToGallery(_ gallery: GalleryEntity) {
        if let artworks = gallery.artworks?.mutableCopy() as? NSMutableSet {
            artworks.add(artwork)
            gallery.artworks = artworks
            try? viewContext.save()
        }
    }
    
    private func removeFromGallery(_ gallery: GalleryEntity) {
        if let artworks = gallery.artworks?.mutableCopy() as? NSMutableSet {
            artworks.remove(artwork)
            gallery.artworks = artworks
            try? viewContext.save()
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
