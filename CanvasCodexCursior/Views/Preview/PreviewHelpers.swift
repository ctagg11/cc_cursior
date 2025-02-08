// Create new file for preview helpers
extension OnboardingPreferences {
    static var preview: OnboardingPreferences {
        var preferences = OnboardingPreferences()
        preferences.firstName = "John"
        preferences.lastName = "Doe"
        preferences.birthDate = Date()
        preferences.experienceLevel = .beginner
        preferences.preferredMediums = [.watercolor, .acrylic]
        preferences.goals = [.improveSkills, .trackProgress]
        return preferences
    }
}

#if DEBUG
extension AuthenticationService {
    static var preview: AuthenticationService {
        let service = AuthenticationService()
        // Add any preview configuration
        return service
    }
}
#endif 