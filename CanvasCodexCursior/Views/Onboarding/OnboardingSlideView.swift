import SwiftUI

struct OnboardingSlideView: View {
    let slide: OnboardingSlide
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 32) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: slide.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: geometry.size.width * 0.5)
                    .opacity(0.1)
                
                Image(systemName: slide.imageName)
                    .font(.system(size: 60))
                    .foregroundColor(slide.gradient[0])
            }
            .frame(height: geometry.size.height * 0.3)
            
            // Text content
            VStack(spacing: 16) {
                Text(slide.title)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text(slide.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top, 60)
    }
}

#Preview {
    GeometryReader { geometry in
        OnboardingSlideView(
            slide: OnboardingSlide(
                title: "Track Your Art Journey",
                description: "Document your progress, organize references, and see your growth over time",
                imageName: "paintpalette.fill",
                gradient: [.purple, .indigo]
            ),
            geometry: geometry
        )
    }
} 