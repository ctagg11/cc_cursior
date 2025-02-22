import SwiftUI
import CoreData

@MainActor
class ProjectViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext
    @Published var projects: [ProjectEntity] = []
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        loadProjects()
    }
    
    func loadProjects() {
        let request = NSFetchRequest<ProjectEntity>(entityName: "ProjectEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ProjectEntity.lastActivityDate, ascending: false)]
        
        do {
            projects = try viewContext.fetch(request)
        } catch {
            print("DEBUG: Error loading projects: \(error)")
        }
    }
    
    func createProject(_ data: ProjectFormData, context: NSManagedObjectContext) throws {
        print("DEBUG: ProjectViewModel: Starting project creation")
        print("DEBUG: ProjectViewModel: Received \(data.references.count) references")
        
        let project = ProjectEntity(context: context)
        project.id = UUID()
        project.name = data.name
        project.medium = data.medium
        project.startDate = data.startDate
        project.lastActivityDate = data.startDate
        project.inspiration = data.inspiration
        project.skills = data.skills
        project.timeEstimate = data.timeEstimate.rawValue
        project.isCompleted = false
        
        // Save references
        for (index, reference) in data.references.enumerated() {
            print("DEBUG: ProjectViewModel: Processing reference \(index + 1)")
            guard let fileName = ImageManager.shared.saveImage(reference.image, category: .reference) else {
                print("DEBUG: ProjectViewModel: Failed to save reference image \(index + 1)")
                continue
            }
            
            let referenceEntity = ReferenceEntity(context: context)
            referenceEntity.id = UUID()
            referenceEntity.imageFileName = fileName
            referenceEntity.title = "Reference Image \(index + 1)"
            project.addToReferences(referenceEntity)
            print("DEBUG: ProjectViewModel: Successfully saved reference \(index + 1) with fileName: \(fileName)")
        }
        
        try context.save()
        print("DEBUG: ProjectViewModel: Project saved with \(project.references?.count ?? 0) references")
        loadProjects()
    }
    
    func saveWorkInProgress(projectName: String, updateTitle: String, changes: String, todoNotes: String, isPublic: Bool, image: UIImage) throws {
        print("DEBUG: Saving work in progress update")
        guard let fileName = ImageManager.shared.saveImage(image, category: .projectUpdate) else {
            throw NSError(domain: "ImageSaveError", code: 1)
        }
        
        let update = ProjectUpdateEntity(context: viewContext)
        update.id = UUID()
        update.title = updateTitle
        update.changes = changes
        update.todoNotes = todoNotes
        update.isPublic = isPublic
        update.imageFileName = fileName
        update.date = Date()
        
        // Find or create project
        let projectFetch: NSFetchRequest<ProjectEntity> = ProjectEntity.fetchRequest()
        projectFetch.predicate = NSPredicate(format: "name == %@", projectName)
        
        if let project = try? viewContext.fetch(projectFetch).first {
            project.addToUpdates(update)
            project.lastActivityDate = update.date
        }
        
        try viewContext.save()
    }
    
    func updateProject(_ project: ProjectEntity, with data: ProjectFormData) throws {
        project.name = data.name
        project.medium = data.medium
        project.startDate = data.startDate
        project.inspiration = data.inspiration
        project.skills = data.skills
        project.timeEstimate = data.timeEstimate.rawValue
        project.priority = data.priority.rawValue
        
        try viewContext.save()
        loadProjects()
    }
    
    func deleteProject(_ project: ProjectEntity) {
        viewContext.delete(project)
        try? viewContext.save()
        loadProjects()
    }
}
