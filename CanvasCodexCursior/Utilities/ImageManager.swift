import UIKit

enum ImageCategory: String {
    case artwork
    case reference
    case projectUpdate
}

class ImageManager {
    static let shared = ImageManager()
    
    private init() {}
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func getCategoryDirectory(_ category: ImageCategory) -> URL {
        let directory = getDocumentsDirectory().appendingPathComponent(category.rawValue)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
    
    func saveImage(_ image: UIImage, category: ImageCategory) -> String? {
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = getCategoryDirectory(category).appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    func loadImage(fileName: String, category: ImageCategory) -> UIImage? {
        let fileURL = getCategoryDirectory(category).appendingPathComponent(fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func deleteImage(fileName: String, category: ImageCategory) {
        let fileURL = getCategoryDirectory(category).appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
} 