import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @EnvironmentObject private var authService: AuthenticationService
    @State private var currentPage = 0
    
    let slides: [OnboardingSlide] = [
        OnboardingSlide(
            title: "Digitize Your Art Journey",
            description: "Transform your physical artwork into beautiful digital galleries with just a scan. Organize and rediscover your creative journey, all in one place.",
            imageName: "camera.viewfinder",
            gradient: [Color.purple, Color.indigo]
        ),
        OnboardingSlide(
            title: "AI-Enhanced Learning",
            description: "Break down techniques, get inspiration from AI collaborator, and watch your skills evolve through guided practice.",
            imageName: "sparkles.rectangle.stack.fill",
            gradient: [Color.teal, Color.mint]
        ),
        OnboardingSlide(
            title: "Join the Creative Community",
            description: "Share your process, get inspired, and connect with fellow artists. Your artistic journey is unique – let's celebrate it together.",
            imageName: "person.2.fill",
            gradient: [Color.orange, Color.pink]
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $currentPage) {
                ForEach(0..<slides.count, id: \.self) { index in
                    ZStack {
                        LinearGradient(
                            colors: slides[index].gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Text("Canvas Codex")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.top, geometry.safeAreaInsets.top + 20)
                            
                            Spacer()
                            
                            Image(systemName: slides[index].imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .foregroundStyle(Color.white)
                                .background(
                                    Circle()
                                        .fill(Color.accentColor.opacity(0.1))
                                        .shadow(radius: 10)
                                )
                                .padding(20)
                            
                            VStack(spacing: 16) {
                                Text(slides[index].title)
                                    .font(.title2)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                
                                Text(slides[index].description)
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.horizontal)
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            if index == slides.count - 1 {
                                Button(action: {
                                    withAnimation {
                                        hasSeenOnboarding = true
                                    }
                                }) {
                                    Text("Get Started")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(LinearGradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                                        .cornerRadius(30)
                                        .shadow(radius: 5)
                                }
                                .padding(.horizontal, 40)
                                .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                            }
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.5), value: currentPage)
        }
        .ignoresSafeArea()
    }
}

struct OnboardingSlide {
    let title: String
    let description: String
    let imageName: String
    let gradient: [Color]
}

#Preview {
    OnboardingView()
        .environmentObject(AuthenticationService())
}

