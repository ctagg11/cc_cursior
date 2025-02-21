import Foundation
import CoreData

extension ProjectEntity {
    var previewImage: Data? {
        guard let updates = updates?.allObjects as? [ProjectUpdateEntity],
              let latestUpdate = updates.max(by: { $0.date ?? Date() < $1.date ?? Date() }) else {
            return nil
        }
        // TODO: Load image data from imageFileName
        return nil
    }
    
    var computedLastActivityDate: Date? {
        guard let updates = updates?.allObjects as? [ProjectUpdateEntity],
              let latestUpdate = updates.max(by: { $0.date ?? Date() < $1.date ?? Date() }) else {
            return nil
        }
        return latestUpdate.date
    }
} 