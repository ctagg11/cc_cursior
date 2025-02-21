import SwiftUI
import os.log

// MARK: - SubCategory
struct SubCategory: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let defaultPrompt: String
    let helperText: String
}

// MARK: - QuickActionsGridView
struct QuickActionsGridView: View {
    @Binding var selectedCategory: QuickActionCategory?
    @Binding var messageText: String
    
    // Animation states
    @State private var isExpanded = false
    @State private var selectedSubCategory: SubCategory?
    
    // Debug logging
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.canvascodex.app",
        category: "QuickActions"
    )
    
    // Grid layout
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // Subcategories for Find Inspiration
    private let inspirationSubCategories = [
        SubCategory(
            title: "Find Reference Works",
            defaultPrompt: "Help me find reference artworks for ",
            helperText: "Describe the style, subject, or theme you're looking for"
        ),
        SubCategory(
            title: "Generate Concept",
            defaultPrompt: "Generate a concept for ",
            helperText: "Describe the type of artwork or project you want to create"
        ),
        SubCategory(
            title: "Explore Color Palettes",
            defaultPrompt: "Suggest a color palette for ",
            helperText: "Describe the mood, theme, or style you want to achieve"
        )
    ]
    
    private func getSubCategories(for category: QuickActionCategory) -> [SubCategory] {
        switch category {
        case .findInspiration:
            return inspirationSubCategories
        default:
            return []
        }
    }
    
    var body: some View {
        VStack {
            if isExpanded {
                // Expanded View
                if let selected = selectedCategory {
                    VStack(spacing: 16) {
                        // Header with back button
                        AnimatedCategoryCard(
                            category: selected,
                            isSelected: true,
                            isExpanded: true
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isExpanded = false
                                selectedCategory = nil
                                selectedSubCategory = nil
                            }
                        }
                        
                        // Category-specific content
                        switch selected {
                        case .findInspiration:
                            ReferenceWorksView()
                        case .reviewArt:
                            // Existing review art functionality
                            EmptyView()
                        case .learnTechniques:
                            // Existing learn techniques functionality
                            EmptyView()
                        case .planProject:
                            // Existing plan project functionality
                            EmptyView()
                        }
                    }
                }
            } else {
                // Grid View
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(QuickActionCategory.allCases, id: \.self) { category in
                        AnimatedCategoryCard(
                            category: category,
                            isSelected: selectedCategory == category,
                            isExpanded: false
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selectedCategory = category
                                isExpanded = true
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .onChange(of: selectedCategory) { newCategory in
            // Debug log
            logger.debug("Selected category changed to: \(newCategory?.rawValue ?? "nil")")
        }
    }
}

// MARK: - QuickActionButton
struct QuickActionButton: View {
    let category: QuickActionCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(category.color.opacity(isSelected ? 1.0 : 0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: category.color.opacity(0.3), radius: 5, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - ScaleButtonStyle
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
} 