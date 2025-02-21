import SwiftUI
import os.log

struct AssistantHeaderView: View {
    // Debug logging
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.canvascodex.app",
        category: "AssistantHeader"
    )
    
    // Animation states
    @State private var isGlowing = false
    @State private var rotation = 0.0
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.6), .purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 70, height: 70)
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isGlowing ? 8 : 0
                    )
                    .scaleEffect(isGlowing ? 1.2 : 1.0)
                    .opacity(isGlowing ? 0.0 : 0.5)
            )
            .overlay(
                Image(systemName: "paintpalette.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 32))
                    .rotationEffect(.degrees(rotation))
            )
            .padding(.vertical, 12)
            .onAppear {
                // Start animations
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    isGlowing = true
                }
                withAnimation(.linear(duration: 12.0).repeatForever(autoreverses: false)) {
                    rotation = 360.0
                }
                
                // Debug log
                logger.debug("AssistantHeaderView appeared")
            }
    }
} 