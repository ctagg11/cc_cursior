import UIKit

public class ImageManager {
    public static let shared = ImageManager()
    
    public enum Category: String {
        case artwork
        case reference
        case projectUpdate
        case component
    }
    
    private init() {}
    
    public func saveImage(_ image: UIImage, category: Category) -> String? {
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
    
    public func loadImage(fileName: String, category: Category) -> UIImage? {
        let fileURL = getDocumentsDirectory()
            .appendingPathComponent(category.rawValue)
            .appendingPathComponent(fileName)
        
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        return nil
    }
    
    private func getDocumentsDirectory() -> URL {
        // Try to use app group container first
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.TagArt.CanvasCodexCursior") {
            return groupURL
        }
        // Fall back to documents directory if app group is not available
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    public func deleteImage(fileName: String, category: Category) {
        let fileURL = getDocumentsDirectory()
            .appendingPathComponent(category.rawValue)
            .appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
} 