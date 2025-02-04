import CoreData

enum PreviewData {
    static var sampleArtwork: ArtworkEntity {
        let context = PersistenceController.preview.container.viewContext
        let artwork = ArtworkEntity(context: context)
        artwork.id = UUID()
        artwork.name = "Sample Artwork"
        artwork.medium = "Digital"
        artwork.createdAt = Date()
        return artwork
    }
} 