import Foundation

struct Gallery: Identifiable, Codable {
    let id: UUID
    var name: String
    var artworkIds: [UUID]
    
    init(id: UUID = UUID(), name: String, artworkIds: [UUID] = []) {
        self.id = id
        self.name = name
        self.artworkIds = artworkIds
    }
} 