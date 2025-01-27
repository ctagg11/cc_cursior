import SwiftUI
import UIKit

enum UploadType {
    case newArtwork
    case workInProgress
}

enum UploadForm: Identifiable {
    case newArtwork(UIImage)
    case workInProgress(UIImage)
    
    var id: String {
        switch self {
        case .newArtwork: return "newArtwork"
        case .workInProgress: return "workInProgress"
        }
    }
} 