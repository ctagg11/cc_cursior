import SwiftUI

// Helper for press events
struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: onPress, onRelease: onRelease))
    }
}

struct AnimatedCategoryCard: View {
    let category: QuickActionCategory
    let isSelected: Bool
    let isExpanded: Bool
    let onSelect: () -> Void
    
    // Animation states
    @State private var isHovered = false
    @State private var isPressed = false
    
    private var gradientColors: [Color] {
        switch category {
        case .reviewArt:
            return [Color(hex: "60a5fa"), Color(hex: "93c5fd")]
        case .findInspiration:
            return [Color(hex: "c084fc"), Color(hex: "d8b4fe")]
        case .chat:
            return [Color(hex: "4ade80"), Color(hex: "86efac")]
        }
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                onSelect()
            }
        }) {
            VStack(spacing: 12) {
                if isExpanded {
                    // Expanded Header View
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Spacer()
                        
                        Text(category.rawValue)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding()
                } else {
                    // Card Content
                    Image(systemName: category.icon)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                    
                    Text(category.rawValue)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: isExpanded ? 60 : 120)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: isExpanded ? 12 : 16))
            .overlay(
                RoundedRectangle(cornerRadius: isExpanded ? 12 : 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: gradientColors[0].opacity(0.3), radius: isHovered ? 8 : 5, y: isHovered ? 4 : 2)
            .scaleEffect(isPressed ? 0.95 : (isHovered ? 1.02 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
} 
