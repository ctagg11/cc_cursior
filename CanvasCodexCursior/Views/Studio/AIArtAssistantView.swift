import SwiftUI
import os.log

// MARK: - AIArtAssistantView
struct AIArtAssistantView: View {
    // MARK: - Properties
    @State private var selectedCategory: QuickActionCategory?
    @State private var messageText: String = ""
    @State private var messages: [AIMessage] = []
    @State private var showingGalleryPicker = false
    @State private var keyboardHeight: CGFloat = 0
    
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
            
            // Quick Actions Grid
            QuickActionsGridView(selectedCategory: $selectedCategory, messageText: $messageText)
                .padding(.horizontal)
            
            // Messages and Input Area
            VStack(spacing: 0) {
                // Messages Area with subtle background
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .background(Color(.systemGray6).opacity(0.3))
                
                // Message Input with slightly darker background
                MessageInputView(text: $messageText) {
                    sendMessage()
                }
                .background(Color(.systemGray6).opacity(0.5))
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $showingGalleryPicker) {
            if let category = selectedCategory {
                ArtworkPickerView(category: category)
            }
        }
        .onChange(of: selectedCategory) { newCategory in
            handleCategorySelection(newCategory)
        }
    }
    
    // MARK: - Helper Methods
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        let content = messageText // Store for logging
        messages.append(AIMessage(
            content: messageText,
            isUser: true,
            attachedImage: nil
        ))
        messageText = ""
        
        // Debug log
        logger.debug("User sent message: \(content)")
    }
    
    private func handleCategorySelection(_ category: QuickActionCategory?) {
        guard let category = category else { return }
        
        // Debug log
        logger.debug("Selected category: \(category.rawValue)")
        
        if category == .reviewArt {
            showingGalleryPicker = true
        }
    }
} 