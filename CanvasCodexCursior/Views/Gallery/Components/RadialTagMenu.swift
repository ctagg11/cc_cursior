import SwiftUI
import Foundation  // Add this to explicitly use Foundation's trig functions

struct RadialTagMenu: View {
    @Binding var isPresented: Bool
    let location: CGPoint
    let onSelectType: (ComponentType) -> Void
    
    @State private var isAnimating = false
    
    private let buttonSize: CGFloat = 44
    private let menuRadius: CGFloat = 80
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .opacity(isAnimating ? 1 : 0)
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isAnimating = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isPresented = false
                        }
                    }
                }
            
            // Radial menu buttons
            ForEach(ComponentType.allCases) { type in
                RadialButton(
                    type: type,
                    position: position(for: type),
                    size: buttonSize,
                    isVisible: isAnimating
                ) {
                    onSelectType(type)
                    isPresented = false
                }
            }
            
            // Center indicator
            Circle()
                .fill(.blue.opacity(0.3))
                .frame(width: 20, height: 20)
                .position(location)
        }
        .onAppear {
            withAnimation(.spring(duration: 0.3)) {
                isAnimating = true
            }
        }
    }
    
    private func position(for type: ComponentType) -> CGPoint {
        let angle: Double
        switch type {
        case .subject:
            angle = .pi * 1.75 // Top right
        case .process:
            angle = .pi * 0.25 // Bottom right
        }
        
        return CGPoint(
            x: location.x + Double(menuRadius) * Foundation.cos(angle),
            y: location.y + Double(menuRadius) * Foundation.sin(angle)
        )
    }
}

struct RadialButton: View {
    let type: ComponentType
    let position: CGPoint
    let size: CGFloat
    let isVisible: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                Text(type.title)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: size, height: size)
            .padding(8)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
        }
        .position(position)
        .scaleEffect(isVisible ? 1 : 0.01)
        .opacity(isVisible ? 1 : 0)
    }
}

#Preview {
    ZStack {
        Color.gray
        RadialTagMenu(
            isPresented: .constant(true),
            location: CGPoint(x: 200, y: 200)
        ) { type in
            print("Selected: \(type)")
        }
    }
} 