import SwiftUI

// MARK: - Theme System
enum AppTheme {
    // MARK: - Colors
    enum Colors {
        static let primary = Color.indigo
        static let secondary = Color.gray
        
        static let background = Color(UIColor.systemGroupedBackground)
        static let cardBackground = Color.white
        static let inputBackground = Color.gray.opacity(0.05)
        
        static let text = Color.primary
        static let textSecondary = Color.secondary
        
        static let success = Color.green
        static let error = Color.red
        static let warning = Color.orange
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Layout
    enum Layout {
        static let cornerRadius: CGFloat = 12
        static let inputCornerRadius: CGFloat = 8
        static let contentMaxWidth: CGFloat = 500
        
        static let shadowRadius: CGFloat = 2
        static let shadowOpacity: CGFloat = 0.05
        static let shadowOffset = CGPoint(x: 0, y: 1)
    }
    
    // MARK: - Animation
    enum Animation {
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.3)
    }
}

// MARK: - View Modifiers
extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.Layout.cornerRadius)
            .shadow(
                color: .black.opacity(AppTheme.Layout.shadowOpacity),
                radius: AppTheme.Layout.shadowRadius,
                y: AppTheme.Layout.shadowOffset.y
            )
    }
    
    func inputStyle() -> some View {
        self
            .padding()
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.Layout.inputCornerRadius)
    }
} 