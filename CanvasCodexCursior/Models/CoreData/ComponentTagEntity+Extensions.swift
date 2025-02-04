import CoreData

extension ComponentTagEntity {
    var type: ComponentType {
        get {
            ComponentType(rawValue: componentType ?? "subject") ?? .subject
        }
        set {
            componentType = newValue.rawValue
        }
    }
    
    var formData: ComponentTagFormData {
        ComponentTagFormData(
            type: type,
            name: name ?? "",
            notes: notes ?? "",
            processSteps: processSteps ?? "",
            rating1: Int(rating1),
            rating2: Int(rating2),
            locationX: locationX,
            locationY: locationY
        )
    }
    
    static func create(from formData: ComponentTagFormData, 
                      artwork: ArtworkEntity,
                      context: NSManagedObjectContext) -> ComponentTagEntity {
        let tag = ComponentTagEntity(context: context)
        tag.id = UUID()
        tag.type = formData.type
        tag.name = formData.name
        tag.notes = formData.notes
        tag.processSteps = formData.processSteps
        tag.rating1 = Int16(formData.rating1)
        tag.rating2 = Int16(formData.rating2)
        tag.locationX = formData.locationX
        tag.locationY = formData.locationY
        tag.createdDate = Date()
        tag.artwork = artwork
        return tag
    }
} 