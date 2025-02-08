import SwiftUI

struct SignupFlow: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthenticationService
    @Binding var preferences: OnboardingPreferences
    @State private var currentStep = 0
    @State private var email = ""
    @State private var password = ""
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentStep) {
                // Personal Info Input (First Step)
                UsernameInputView(
                    firstName: $preferences.firstName,
                    lastName: $preferences.lastName,
                    birthDate: $preferences.birthDate,
                    onNext: {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                )
                .tag(0)
                
                // Experience Level
                PreferenceSelectionView(
                    title: "Your Experience",
                    description: "Help us personalize your experience",
                    selection: $preferences.experienceLevel,
                    onNext: {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                )
                .tag(1)
                
                // Art Mediums
                MultiSelectionView(
                    title: "Preferred Mediums",
                    description: "Select all that you use",
                    selection: $preferences.preferredMediums,
                    onNext: {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                )
                .tag(2)
                
                // Goals
                MultiSelectionView(
                    title: "Your Goals",
                    description: "What would you like to achieve?",
                    selection: $preferences.goals,
                    onNext: {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                )
                .tag(3)
                
                // Account Creation
                AccountCreationView(
                    email: $email,
                    password: $password,
                    onComplete: { 
                        Task {
                            do {
                                try await authService.createAccount(email: email, password: password)
                                hasSeenOnboarding = true
                                dismiss()
                            } catch {
                                // Handle error
                                print("Failed to create account: \(error.localizedDescription)")
                            }
                        }
                    }
                )
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .interactiveDismissDisabled()
        .onChange(of: authService.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                hasSeenOnboarding = true
                dismiss()
            }
        }
    }
}

#Preview {
    SignupFlow(preferences: .constant(OnboardingPreferences()))
        .environmentObject(AuthenticationService())
}

extension OnboardingPreferences {
    static var sample: OnboardingPreferences {
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