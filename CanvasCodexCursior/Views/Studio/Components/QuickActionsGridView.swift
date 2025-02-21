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
    @State private var shouldNavigateToChat = false
    @State private var showingChatSheet = false
    
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
            title: "Generate AI Reference Material",
            defaultPrompt: "Help me generate reference material for ",
            helperText: "Describe the type of reference material you're looking for"
        ),
        SubCategory(
            title: "Explore and Learn Techniques",
            defaultPrompt: "Help me learn about techniques for ",
            helperText: "What techniques would you like to explore?"
        ),
        SubCategory(
            title: "Color Palette Generation",
            defaultPrompt: "Help me generate a color palette for ",
            helperText: "Describe the mood or style you want to achieve"
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
            if selectedCategory != nil {
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
                                selectedCategory = nil
                                selectedSubCategory = nil
                            }
                        }
                        
                        // Category-specific content
                        switch selected {
                        case .reviewArt:
                            ArtworkReviewFlow(shouldNavigateToChat: $shouldNavigateToChat)
                                .transition(.opacity.combined(with: .move(edge: .trailing)))
                        case .findInspiration:
                            // Subcategories
                            VStack(spacing: 12) {
                                ForEach(getSubCategories(for: selected)) { subCategory in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            if selectedSubCategory == subCategory {
                                                selectedSubCategory = nil
                                            } else {
                                                selectedSubCategory = subCategory
                                                messageText = subCategory.defaultPrompt
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(subCategory.title)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            
                                            Spacer()
                                            
                                            if selectedSubCategory == subCategory {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(selected.color)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemGray6))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(
                                                            selectedSubCategory == subCategory ? selected.color : Color.clear,
                                                            lineWidth: 2
                                                        )
                                                )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            
                            // Reference Works Options
                            if let subCategory = selectedSubCategory {
                                if subCategory.title == "Color Palette Generation" {
                                    ColorPaletteGenerator()
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                } else if subCategory.title == "Explore and Learn Techniques" {
                                    TechniqueExplorerView()
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                } else if subCategory.title == "Find Reference Works" {
                                    VStack(spacing: 12) {
                                        ForEach(ReferenceOption.allCases, id: \.self) { option in
                                            Button {
                                                // Handle reference option selection
                                            } label: {
                                                HStack {
                                                    Image(systemName: option.icon)
                                                        .font(.system(size: 18))
                                                    Text(option.rawValue)
                                                        .font(.subheadline)
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .padding(.horizontal, 16)
                                                .background(Color(.systemGray6))
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                            .foregroundColor(.primary)
                                        }
                                    }
                                    .padding(.top, 8)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                            
                            // Helper text
                            if let subCategory = selectedSubCategory {
                                Text(subCategory.helperText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 4)
                                    .transition(.opacity)
                            }
                        default:
                            EmptyView()
                        }
                    }
                }
            } else {
                // Grid View
                VStack(spacing: 16) {
                    // Top row with two buttons
                    HStack(spacing: 16) {
                        QuickActionButton(
                            category: .reviewArt,
                            isSelected: selectedCategory == .reviewArt,
                            action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedCategory = .reviewArt
                                    isExpanded = true
                                }
                            }
                        )
                        
                        QuickActionButton(
                            category: .findInspiration,
                            isSelected: selectedCategory == .findInspiration,
                            action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedCategory = .findInspiration
                                    isExpanded = true
                                }
                            }
                        )
                    }
                    
                    // Bottom full-width button
                    QuickActionButton(
                        category: .chat,
                        isSelected: selectedCategory == .chat,
                        action: {
                            logger.debug("Opening chat sheet directly")
                            showingChatSheet = true
                        }
                    )
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showingChatSheet) {
            AIChatSheet(
                initialPrompt: "",
                artworkImage: nil,
                artworkTitle: nil
            )
        }
        .onChange(of: selectedCategory) { newCategory in
            logger.debug("Selected category changed to: \(newCategory?.rawValue ?? "nil")")
        }
    }
}

// MARK: - Reference Option
enum ReferenceOption: String, CaseIterable {
    case upload = "Upload Reference"
    case describe = "Describe Subject"
    case browse = "Browse Categories"
    
    var icon: String {
        switch self {
        case .upload: return "square.and.arrow.up"
        case .describe: return "text.magnifyingglass"
        case .browse: return "square.grid.2x2"
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
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(category.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .frame(height: category == .chat ? 120 : 160)
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(category.color.opacity(isSelected ? 1.0 : 0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
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