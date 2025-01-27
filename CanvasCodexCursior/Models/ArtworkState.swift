import Foundation


enum ArtworkStatus: Codable {
    case inProgress
    case completed
}

struct Artwork: Identifiable, Codable {
    let id: UUID
    var name: String
    var startDate: Date?
    var completionDate: Date?
    var medium: String
    var dimensions: String?
    var inspirationNotes: String?
    var imageURL: URL
    var referenceImageURLs: [URL]
    var galleries: [String] // Gallery names
    var status: ArtworkStatus
    var isPublic: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, startDate, completionDate, medium, dimensions
        case inspirationNotes, imageURL, referenceImageURLs, galleries
        case status, isPublic
    }
    
    init(id: UUID = UUID(), name: String = "", medium: String = "", status: ArtworkStatus = .inProgress, isPublic: Bool = false) {
        self.id = id
        self.name = name
        self.medium = medium
        self.status = status
        self.isPublic = isPublic
        self.imageURL = URL(fileURLWithPath: "")
        self.referenceImageURLs = []
        self.galleries = []
    }
} 
