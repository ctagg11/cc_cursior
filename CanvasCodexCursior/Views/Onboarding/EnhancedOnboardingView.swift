import SwiftUI

struct EnhancedOnboardingView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var currentPage = 0
    @State private var showingLogin = false
    @State private var showingSignup = false
    @State private var preferences = OnboardingPreferences()
    
    let slides: [OnboardingSlide] = [
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
    
    var body: some View {
        ZStack {
            // Background gradient that changes with page
            LinearGradient(
                colors: slides[currentPage].gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            VStack(spacing: 0) {
                // Sliding content
                TabView(selection: $currentPage) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        VStack(spacing: 40) {
                            Spacer()
                                .frame(height: 60)
                            
                            // Icon
                            Image(systemName: slides[index].imageName)
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                                .padding(.bottom, 20)
                            
                            // Text Content
                            VStack(spacing: 20) {
                                Text(slides[index].title)
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                Text(slides[index].description)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                            
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Fixed bottom section
                VStack(spacing: 32) {
                    // Page Indicator Dots
                    HStack(spacing: 8) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.white : Color.white.opacity(0.5))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button {
                            showingSignup = true
                        } label: {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(slides[currentPage].gradient[0])
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        
                        Button {
                            showingLogin = true
                        } label: {
                            Text("I already have an account")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showingSignup) {
            SignupFlow(preferences: $preferences)
        }
        .sheet(isPresented: $showingLogin) {
            LoginView()
        }
    }
}

// Add this view for username input
struct UsernameInputView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var birthDate: Date
    @Binding var gender: String
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Create Your Profile")
                .font(.title2.bold())
            
            Text("This will give you a place to store your artwork and help your friends find you")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(.roundedBorder)
                
                DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                
                Picker("Gender", selection: $gender) {
                    Text("Select Gender").tag("")
                    Text("Female").tag("female")
                    Text("Male").tag("male")
                    Text("Prefer not to say").tag("undisclosed")
                }
            }
            .padding(.horizontal)
            
            Button {
                if !firstName.isEmpty && !lastName.isEmpty {
                    onNext()
                }
            } label: {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(firstName.isEmpty || lastName.isEmpty ? Color.gray : Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(firstName.isEmpty || lastName.isEmpty)
        }
        .padding()
    }
}

#Preview("Onboarding Flow") {
    EnhancedOnboardingView()
        .environmentObject(AuthenticationService())
}

#Preview("All Pages") {
    VStack(spacing: 20) {
        ForEach(0..<4) { index in
            EnhancedOnboardingView(currentPage: index)
                .environmentObject(AuthenticationService())
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
        }
    }
    .padding(.vertical)
}

// Add this initializer to support the preview
extension EnhancedOnboardingView {
    init(currentPage: Int = 0) {
        _currentPage = State(initialValue: currentPage)
    }
} 
