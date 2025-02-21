import SwiftUI
import os.log

// MARK: - AIArtAssistantView
struct AIArtAssistantView: View {
    // MARK: - Properties
    @State private var selectedCategory: QuickActionCategory?
    @State private var showingGalleryPicker = false
    
    // Debug logging
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.canvascodex.app",
        category: "AIArtAssistant"
    )
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            if selectedCategory == nil {
                // Assistant Header - only show on main landing page
                AssistantHeaderView()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = nil
                            showingGalleryPicker = false
                        }
                    }
            } else {
                // Add padding when header is hidden
                Spacer()
                    .frame(height: 16)
            }
            
            // Content
            if selectedCategory == .reviewArt {
                ArtworkReviewFlow(shouldNavigateToChat: $showingGalleryPicker)
                    .padding([.horizontal, .bottom])
            } else if selectedCategory == .findInspiration {
                QuickActionsGridView(selectedCategory: $selectedCategory, messageText: .constant(""))
                    .padding([.horizontal, .bottom])
            } else if selectedCategory == nil {
                QuickActionsGridView(selectedCategory: $selectedCategory, messageText: .constant(""))
                    .padding([.horizontal, .bottom])
            }
            
            Spacer(minLength: 0)
        }
        .onChange(of: selectedCategory) { newCategory in
            handleCategorySelection(newCategory)
        }
    }
    
    // MARK: - Helper Methods
    private func handleCategorySelection(_ category: QuickActionCategory?) {
        guard let category = category else { return }
        
        // Debug log
        logger.debug("Selected category: \(category.rawValue)")
        
        if category == .reviewArt {
            showingGalleryPicker = true
        }
    }
} 