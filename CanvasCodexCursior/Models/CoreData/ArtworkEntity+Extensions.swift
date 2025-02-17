import CoreData

extension ArtworkEntity {
    @objc var order: NSNumber? {
        get {
            // Try to get sortOrder if it exists, otherwise return 0
            if let sortOrder = value(forKey: "sortOrder") as? Int32 {
                return NSNumber(value: sortOrder)
            }
            return 0
        }
        set {
            // Set sortOrder if it exists
            if responds(to: NSSelectorFromString("sortOrder")) {
                setValue(newValue?.int32Value ?? 0, forKey: "sortOrder")
            }
        }
    }

    // Helper method to update sort order
    func updateSortOrder(_ newOrder: Int) {
        self.sortOrder = Int32(newOrder)
    }
} 