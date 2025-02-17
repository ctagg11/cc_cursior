import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct DragDropComponents {
    struct ItemProvider: Identifiable {
        let id: UUID
        let provider: NSItemProvider
    }
}

class DropViewDelegate: DropDelegate {
    let item: ArtworkEntity
    let items: [ArtworkEntity]
    let viewContext: NSManagedObjectContext
    let onDragStarted: () -> Void
    let onDragEnded: () -> Void
    
    init(
        item: ArtworkEntity,
        items: [ArtworkEntity],
        viewContext: NSManagedObjectContext,
        onDragStarted: @escaping () -> Void = {},
        onDragEnded: @escaping () -> Void = {}
    ) {
        self.item = item
        self.items = items
        self.viewContext = viewContext
        self.onDragStarted = onDragStarted
        self.onDragEnded = onDragEnded
    }
    
    func dropEntered(info: DropInfo) {
        onDragStarted()
    }
    
    func dropExited(info: DropInfo) {
        onDragEnded()
    }
    
    func performDrop(info: DropInfo) -> Bool {
        let generators = info.itemProviders(for: [UTType.plainText])
        guard let provider = generators.first,
              let fromIndex = items.firstIndex(of: item) else {
            return false
        }
        
        provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (data, error) in
            guard let data = data as? Data,
                  let id = try? JSONDecoder().decode(UUID.self, from: data),
                  let toIndex = self.items.firstIndex(where: { $0.id == id }) else {
                return
            }
            
            DispatchQueue.main.async {
                // Create haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                // Update the order
                var updatedItems = self.items
                updatedItems.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex)
                
                // Update sort order in Core Data
                for (index, artwork) in updatedItems.enumerated() {
                    artwork.updateSortOrder(index)
                }
                
                try? self.viewContext.save()
            }
        }
        return true
    }
} 