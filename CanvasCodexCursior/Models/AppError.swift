enum AppError: LocalizedError {
    case authentication
    case networkError
    case databaseError(String)
    case imageProcessingError
    case invalidData
    case dataPersistenceError
    
    var errorDescription: String? {
        switch self {
        case .authentication:
            return "Authentication error. Please sign in again."
        case .networkError:
            return "Network error. Please check your connection."
        case .databaseError(let message):
            return "Database error: \(message)"
        case .imageProcessingError:
            return "Failed to process image."
        case .invalidData:
            return "Invalid data received."
        case .dataPersistenceError:
            return "Failed to persist data between sessions."
        }
    }
} 