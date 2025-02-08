import Foundation
import SwiftUI

// User preferences during onboarding
struct OnboardingPreferences: Codable {
    var firstName: String = ""
    var lastName: String = ""
    var birthDate: Date = Date()
    var gender: String = ""
    var experienceLevel: ExperienceLevel = .beginner
    var preferredMediums: [ArtMedium] = []
    var goals: [ArtisticGoal] = []
    var weeklyHours: WeeklyArtTime = .lessThanTwo
    
    // For analytics and personalization
    var hasCompletedTutorial: Bool = false
    var dateJoined: Date = Date()
    
    // Add coding keys to ensure proper encoding/decoding
    enum CodingKeys: String, CodingKey {
        case firstName, lastName, birthDate, gender
        case experienceLevel, preferredMediums, goals
        case weeklyHours, hasCompletedTutorial, dateJoined
    }
}

enum ExperienceLevel: String, Codable, CaseIterable, Identifiable {
    case beginner = "Just Starting Out"
    case intermediate = "Some Experience"
    case advanced = "Experienced Artist"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .beginner: 
            return "New to art or getting back into it"
        case .intermediate:
            return "Regular practice, developing skills"
        case .advanced:
            return "Consistent practice, refined techniques"
        }
    }
}

enum ArtMedium: String, Codable, CaseIterable, Identifiable {
    case digitalArt = "Digital Art"
    case pencil = "Pencil/Graphite"
    case watercolor = "Watercolor"
    case acrylic = "Acrylic"
    case oils = "Oil Paint"
    case mixedMedia = "Mixed Media"
    case other = "Other"
    
    var id: String { rawValue }
}

enum ArtisticGoal: String, Codable, CaseIterable, Identifiable {
    case improveSkills = "Improve Techniques"
    case buildPortfolio = "Build Portfolio"
    case trackProgress = "Track Progress"
    case stayMotivated = "Stay Motivated"
    case joinCommunity = "Join Community"
    
    var id: String { rawValue }
}

enum WeeklyArtTime: String, Codable, CaseIterable, Identifiable {
    case lessThanTwo = "0-2 hours"
    case twoToFive = "2-5 hours"
    case fiveToTen = "5-10 hours"
    case moreThanTen = "10+ hours"
    
    var id: String { rawValue }
}

// Add this struct to the existing file
struct OnboardingSlide: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let gradient: [Color]
}

// Add static slides to reduce duplication
extension OnboardingSlide {
    static let slides: [OnboardingSlide] = [
        OnboardingSlide(
            title: "Welcome to Canvas Codex",
            description: "Your digital art companion for growth and inspiration",
            imageName: "paintpalette.fill",
            gradient: [Color.purple, Color.indigo]
        ),
        OnboardingSlide(
            title: "Track Your Art Journey",
            description: "Document your progress, organize references, and see your growth over time",
            imageName: "rectangle.stack.fill",
            gradient: [Color.teal, Color.mint]
        ),
        OnboardingSlide(
            title: "AI-Enhanced Learning",
            description: "Get personalized insights and break down techniques with AI assistance",
            imageName: "sparkles.rectangle.stack.fill",
            gradient: [Color.blue, Color.purple]
        ),
        OnboardingSlide(
            title: "Join the Community",
            description: "Connect with fellow artists, share your process, and get inspired",
            imageName: "person.2.fill",
            gradient: [Color.orange, Color.pink]
        )
    ]
} 
