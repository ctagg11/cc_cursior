import SwiftUI

struct EnhancedOnboardingView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var currentPage = 0
    @State private var showingLogin = false
    @State private var showingSignup = false
    @State private var preferences = OnboardingPreferences()
    
    var body: some View {
        ZStack {
            // Background gradient that changes with page
            LinearGradient(
                colors: OnboardingSlide.slides[currentPage].gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            VStack(spacing: 0) {
                // Sliding content
                TabView(selection: $currentPage) {
                    ForEach(0..<OnboardingSlide.slides.count, id: \.self) { index in
                        VStack(spacing: 40) {
                            Spacer()
                                .frame(height: 60)
                            
                            // Icon
                            Image(systemName: OnboardingSlide.slides[index].imageName)
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                                .padding(.bottom, 20)
                            
                            // Text Content
                            VStack(spacing: 20) {
                                Text(OnboardingSlide.slides[index].title)
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                Text(OnboardingSlide.slides[index].description)
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
                        ForEach(0..<OnboardingSlide.slides.count, id: \.self) { index in
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
                                .foregroundColor(OnboardingSlide.slides[currentPage].gradient[0])
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
