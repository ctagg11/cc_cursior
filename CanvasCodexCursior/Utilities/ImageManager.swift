import UIKit

class ImageManager {
    static let shared = ImageManager()
    
    enum Category: String {
        case artwork
        case reference
        case projectUpdate
        case component
    }
    
    private init() {}
    
    func saveImage(_ image: UIImage, category: Category) -> String? {
        let fileName = UUID().uuidString
        let fileURL = getDocumentsDirectory()
            .appendingPathComponent(category.rawValue)
            .appendingPathComponent(fileName)
        
        // Create category directory if it doesn't exist
        try? FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
            return fileName
        }
        return nil
    }
    
    func loadImage(fileName: String, category: Category) -> UIImage? {
        let fileURL = getDocumentsDirectory()
            .appendingPathComponent(category.rawValue)
            .appendingPathComponent(fileName)
        
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        return nil
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func deleteImage(fileName: String, category: Category) {
        let fileURL = getDocumentsDirectory()
            .appendingPathComponent(category.rawValue)
            .appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
} 