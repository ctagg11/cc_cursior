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
            // Assistant Header
            AssistantHeaderView()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedCategory = nil
                        showingGalleryPicker = false
                    }
                }
            
            // Quick Actions Grid
            if selectedCategory == .reviewArt {
                ArtworkReviewFlow(shouldNavigateToChat: $showingGalleryPicker)
                    .padding([.horizontal, .bottom])
            } else {
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