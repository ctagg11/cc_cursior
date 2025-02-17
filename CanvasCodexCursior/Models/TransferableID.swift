import SwiftUI
import UniformTypeIdentifiers

struct TransferableID: Transferable, Codable {
    let id: UUID
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .plainText) // Using plainText since UUID doesn't have a specific UTType
    }
} 