import CoreData
import UIKit
import SwiftUI

class ArtworkViewModel: ObservableObject {
    private let viewContext = PersistenceController.shared.container.viewContext
    
    @Published private(set) var galleries: [GalleryEntity] = []
    @Published var projects: [ProjectEntity] = []
    @Published var artworks: [ArtworkEntity] = []
    
    func saveNewArtwork(formData: ArtworkFormData, image: UIImage, gallery: String?) throws {
        // Save image first
        guard let fileName = ImageManager.shared.saveImage(image, category: .artwork) else {
            throw ArtworkError.imageSaveError
        }
        
        // Create new artwork entity
        let artwork = ArtworkEntity(context: viewContext)
        artwork.id = UUID()
        artwork.name = formData.name
        artwork.medium = formData.medium
        artwork.imageFileName = fileName
        artwork.createdAt = Date()
        artwork.startDate = formData.startDate
        artwork.completionDate = formData.completionDate
        artwork.dimensionType = formData.dimensionType == .twoDimensional ? "2D" : "3D"
        artwork.width = formData.width
        artwork.height = formData.height
        artwork.depth = formData.depth
        artwork.units = formData.units.rawValue
        
        // Add to gallery if specified
        if let galleryName = gallery {
            let fetchRequest: NSFetchRequest<GalleryEntity> = GalleryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", galleryName)
            
            if let galleryEntity = try? viewContext.fetch(fetchRequest).first {
                artwork.addToGalleries(galleryEntity)
            }
        }
        
        // Save context
        try viewContext.save()
        
        // Refresh galleries
        loadGalleries()
    }
    
    func saveWorkInProgress(projectName: String, updateTitle: String, changes: String, todoNotes: String, isPublic: Bool, image: UIImage) throws {
        guard let fileName = ImageManager.shared.saveImage(image, category: .projectUpdate) else {
            throw NSError(domain: "ImageSaveError", code: 1)
        }
        
        // Find or create project
        let projectFetch: NSFetchRequest<ProjectEntity> = ProjectEntity.fetchRequest()
        projectFetch.predicate = NSPredicate(format: "name == %@", projectName)
        
        let project: ProjectEntity
        if let existingProject = try viewContext.fetch(projectFetch).first {
            project = existingProject
        } else {
            project = ProjectEntity(context: viewContext)
            project.id = UUID()
            project.name = projectName
            project.isCompleted = false
        }
        
        // Create update
        let update = ProjectUpdateEntity(context: viewContext)
        update.id = UUID()
        update.title = updateTitle
        update.changes = changes
        update.todoNotes = todoNotes
        update.isPublic = isPublic
        update.imageFileName = fileName
        update.date = Date()
        
        project.addToUpdates(update)
        project.lastActivityDate = update.date
        
        try viewContext.save()
    }
    
    func saveReference(title: String, notes: String, image: UIImage, artworkId: UUID?) throws {
        guard let fileName = ImageManager.shared.saveImage(image, category: .reference) else {
            throw NSError(domain: "ImageSaveError", code: 1)
        }
        
        let reference = ReferenceEntity(context: viewContext)
        reference.id = UUID()
        reference.title = title
        reference.notes = notes
        reference.imageFileName = fileName
        
        if let artworkId = artworkId {
            let artworkFetch: NSFetchRequest<ArtworkEntity> = ArtworkEntity.fetchRequest()
            artworkFetch.predicate = NSPredicate(format: "id == %@", artworkId as CVarArg)
            if let artwork = try viewContext.fetch(artworkFetch).first {
                artwork.addToReferences(reference)
            }
        }
        
        try viewContext.save()
    }
    
    private func findOrCreateGallery(name: String) throws -> GalleryEntity {
        let fetch: NSFetchRequest<GalleryEntity> = GalleryEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "name == %@", name)
        
        if let existing = try viewContext.fetch(fetch).first {
            return existing
        }
        
        let gallery = GalleryEntity(context: viewContext)
        gallery.id = UUID()
        gallery.name = name
        return gallery
    }
    
    func loadGalleries() {
        let fetch: NSFetchRequest<GalleryEntity> = GalleryEntity.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \GalleryEntity.name, ascending: true)]
        
        do {
            galleries = try viewContext.fetch(fetch)
        } catch {
            print("Failed to fetch galleries: \(error)")
        }
    }
    
    func createGallery(name: String) throws -> GalleryEntity {
        // Check for duplicate names
        let fetch: NSFetchRequest<GalleryEntity> = GalleryEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "name == %@", name)
        
        if try viewContext.fetch(fetch).first != nil {
            throw NSError(domain: "GalleryError", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "A gallery with this name already exists"
            ])
        }
        
        let gallery = GalleryEntity(context: viewContext)
        gallery.id = UUID()
        gallery.name = name
        
        try viewContext.save()
        loadGalleries() // Refresh the galleries list
        return gallery
    }
    
    func loadProjects() {
        let request = ProjectEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ProjectEntity.name, ascending: true)]
        
        do {
            projects = try viewContext.fetch(request)
        } catch {
            print("Error loading projects: \(error)")
        }
    }
    
    func createProject(with formData: ProjectFormData) throws -> ProjectEntity {
        let project = ProjectEntity(context: viewContext)
        project.id = UUID()
        project.name = formData.name
        project.medium = formData.medium
        project.startDate = formData.startDate
        project.inspiration = formData.inspiration
        project.skills = formData.skills
        project.timeEstimate = formData.timeEstimate.rawValue
        project.difficultyLevel = formData.difficultyLevel.rawValue
        project.lastActivityDate = Date()
        project.isCompleted = false
        
        try viewContext.save()
        return project
    }
    
    func updateProject(_ project: ProjectEntity, with formData: ProjectFormData) throws {
        project.name = formData.name
        project.medium = formData.medium
        project.startDate = formData.startDate
        project.inspiration = formData.inspiration
        project.skills = formData.skills
        project.timeEstimate = formData.timeEstimate.rawValue
        project.difficultyLevel = formData.difficultyLevel.rawValue
        project.lastActivityDate = Date()
        
        try viewContext.save()
    }
    
    func addReference(to project: ProjectEntity, image: UIImage) throws {
        guard let fileName = ImageManager.shared.saveImage(image, category: .reference) else {
            throw NSError(domain: "ImageSaveError", code: 1)
        }
        
        let reference = ReferenceEntity(context: viewContext)
        reference.id = UUID()
        reference.imageFileName = fileName
        project.addToReferences(reference)
        
        try viewContext.save()
    }
    
    func createArtwork(_ formData: ArtworkFormData, image: UIImage, referenceImage: UIImage?) throws {
        guard let fileName = ImageManager.shared.saveImage(image, category: .artwork) else {
            throw NSError(domain: "ImageSaveError", code: 1)
        }
        
        let artwork = ArtworkEntity(context: viewContext)
        artwork.id = UUID()
        artwork.name = formData.name
        artwork.medium = formData.medium
        artwork.imageFileName = fileName
        artwork.startDate = formData.startDate
        artwork.completionDate = formData.completionDate
        artwork.createdAt = Date()
        artwork.isPublic = false  // Set a default value
        
        // Set dimensions if provided
        artwork.width = formData.width
        artwork.height = formData.height
        artwork.depth = formData.depth
        artwork.units = formData.units.rawValue
        
        // Add to gallery if specified
        if let galleryId = UUID(uuidString: formData.galleryId) {
            let fetchRequest: NSFetchRequest<GalleryEntity> = GalleryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", galleryId as CVarArg)
            
            if let galleryEntity = try? viewContext.fetch(fetchRequest).first {
                artwork.addToGalleries(galleryEntity)
            }
        }
        
        if let referenceImage = referenceImage,
           let referenceData = referenceImage.jpegData(compressionQuality: 0.8) {
            artwork.referenceImageData = referenceData
        }
        
        // Save context
        try viewContext.save()
        
        // Refresh galleries
        loadGalleries()
    }
    
    func addUpdate(to project: ProjectEntity, update: ProjectUpdateEntity) {
        project.addToUpdates(update)
        project.lastActivityDate = update.date
        try? viewContext.save()
    }
    
    func deleteArtwork(_ artwork: ArtworkEntity) {
        // Ensure we're on the main thread
        DispatchQueue.main.async {
            // Verify the artwork still exists in our array
            guard self.artworks.contains(artwork) else { return }
            
            // Remove from the array first
            if let index = self.artworks.firstIndex(of: artwork) {
                self.artworks.remove(at: index)
            }
            
            // Then delete from Core Data
            self.viewContext.delete(artwork)
            
            // Save context
            do {
                try self.viewContext.save()
            } catch {
                print("Error deleting artwork: \(error)")
                // Optionally reload data to ensure consistency
                self.fetchArtworks()
            }
        }
    }
    
    func fetchArtworks() {
        let request = NSFetchRequest<ArtworkEntity>(entityName: "ArtworkEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ArtworkEntity.createdAt, ascending: false)]
        
        do {
            artworks = try viewContext.fetch(request)
        } catch {
            print("Error fetching artworks: \(error)")
            artworks = []
        }
    }
    


}

enum ArtworkError: LocalizedError {
    case imageSaveError
    case galleryNotFound
    
    var errorDescription: String? {
        switch self {
        case .imageSaveError:
            return "Failed to save artwork image"
        case .galleryNotFound:
            return "Selected gallery not found"
        }
    }
} 
