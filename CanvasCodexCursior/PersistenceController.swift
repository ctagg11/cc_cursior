import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CanvasCodexCursior")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Use the shared app group container for persistence
            if let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.TagArt.CanvasCodexCursior") {
                let storeDescription = NSPersistentStoreDescription(url: storeURL.appendingPathComponent("CanvasCodexCursior.sqlite"))
                container.persistentStoreDescriptions = [storeDescription]
            }
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        // Enable persistent history tracking for merge policies
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()
}

