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
    @State private var showingTagMode = false
    @FetchRequest private var tags: FetchedResults<ComponentTagEntity>
    
    // Fetch request for available galleries
    @FetchRequest(
        entity: GalleryEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GalleryEntity.name, ascending: true)
        ]
    ) private var galleries: FetchedResults<GalleryEntity>
    
    public init(artwork: ArtworkEntity) {
        self.artwork = artwork
        _tags = FetchRequest(
            entity: ComponentTagEntity.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \ComponentTagEntity.createdDate, ascending: true)],
            predicate: NSPredicate(format: "artwork == %@", artwork)
        )
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
                        .padding(.horizontal)
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
                
                // Add Tag Components Button
                Button {
                    showingTagMode = true
                } label: {
                    HStack {
                        Image(systemName: "tag")
                        Text("Tag Components")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
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
        .fullScreenCover(isPresented: $showingTagMode) {
            if let fileName = artwork.imageFileName,
               let uiImage = ImageManager.shared.loadImage(fileName: fileName, category: .artwork) {
                FullScreenTagMode(image: uiImage, artwork: artwork)
            }
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

// New Full Screen Tag Mode View
struct FullScreenTagMode: View {
    let image: UIImage
    let artwork: ArtworkEntity
    @Environment(\.dismiss) private var dismiss
    @FetchRequest private var tags: FetchedResults<ComponentTagEntity>
    @State private var showingContextualForm = false
    @State private var tagLocation: CGPoint = .zero
    
    init(image: UIImage, artwork: ArtworkEntity) {
        self.image = image
        self.artwork = artwork
        _tags = FetchRequest(
            entity: ComponentTagEntity.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \ComponentTagEntity.createdDate, ascending: true)],
            predicate: NSPredicate(format: "artwork == %@", artwork)
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                ZStack {
                    // Main Image
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    
                    // Grid Overlay - more subtle
                    GridOverlay()
                    
                    // Show selection dot when form is visible
                    if showingContextualForm {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .position(tagLocation)
                    }
                    
                    // Existing Tags
                    ForEach(tags) { tag in
                        TagIndicator(tag: tag)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    LongPressGesture(minimumDuration: 0.2)
                        .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
                        .onChanged { value in
                            switch value {
                            case .second(true, let drag):
                                guard !showingContextualForm else { return }
                                if let drag = drag {
                                    let location = drag.location
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    tagLocation = location
                                    withAnimation(.spring(duration: 0.3)) {
                                        showingContextualForm = true
                                    }
                                }
                            default:
                                break
                            }
                        }
                )
                
                // Header Instructions - now on top
                VStack {
                    Text("Artwork Component Tagging")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Long hold to tag individual subjects or techniques to add to your component library")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 40)
                
                // Close Button
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                                .padding()
                        }
                    }
                    Spacer()
                }
                
                // Legend
                VStack {
                    Spacer()
                    HStack {
                        TagLegendItem(type: .subject)
                        TagLegendItem(type: .process)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom)
                }
                
                if showingContextualForm {
                    ContextualTagForm(
                        isPresented: $showingContextualForm,
                        location: tagLocation,
                        artwork: artwork
                    )
                    .clipped() // Prevent form from extending outside screen
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct TagLegendItem: View {
    let type: ComponentType
    
    var body: some View {
        HStack {
            Circle()
                .fill(type == .subject ? .blue.opacity(0.2) : .orange.opacity(0.2))
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(type == .subject ? .blue : .orange, lineWidth: 1)
                )
            Text(type == .subject ? "Subject" : "Process")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
    }
}
