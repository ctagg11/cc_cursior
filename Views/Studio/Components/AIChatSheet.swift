import SwiftUI
import os.log

// MARK: - Assistant State
enum AssistantState {
    case idle
    case thinking
    case answering
    
    var animation: Animation {
        switch self {
        case .idle:
            return .linear(duration: 2.0).repeatForever(autoreverses: true)
        case .thinking:
            return .easeInOut(duration: 0.5).repeatForever(autoreverses: true)
        case .answering:
            return .spring(response: 0.6, dampingFraction: 0.7)
        }
    }
}

// MARK: - AIChatSheet
struct AIChatSheet: View {
    // Debug logging
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.canvascodex.app",
        category: "AIChat"
    )
    
    // Environment
    @Environment(\.dismiss) private var dismiss
    
    // State
    @State private var messages: [AIMessage] = []
    @State private var inputText = ""
    @State private var assistantState: AssistantState = .idle
    @State private var showingSaveOptions = false
    
    // Input parameters
    let initialPrompt: String
    let artworkImage: UIImage?
    let artworkTitle: String?
    
    // Animation states
    @State private var isGlowing = false
    @State private var rotation = 0.0
    @State private var scale = 1.0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Assistant Header
                assistantHeader
                    .padding(.vertical)
                
                // Chat Content
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Initial Context
                            if let image = artworkImage {
                                artworkPreview(image)
                            }
                            
                            // Messages
                            ForEach(messages, id: \.timestamp) { message in
                                MessageBubbleView(message: message)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(messages.last?.timestamp, anchor: .bottom)
                        }
                    }
                }
                
                // Input Area
                inputArea
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        if !messages.isEmpty {
                            showingSaveOptions = true
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    if let title = artworkTitle {
                        Text(title)
                            .font(.headline)
                    }
                }
            }
            .onAppear {
                // Start with the initial prompt
                if !initialPrompt.isEmpty {
                    sendMessage(initialPrompt)
                }
                logger.debug("Chat sheet appeared with initial prompt: \(initialPrompt)")
            }
            .confirmationDialog(
                "Save Conversation?",
                isPresented: $showingSaveOptions,
                titleVisibility: .visible
            ) {
                Button("Save to Artwork/Project") {
                    // TODO: Implement save functionality
                    logger.debug("User chose to save conversation")
                    dismiss()
                }
                
                Button("Discard", role: .destructive) {
                    logger.debug("User chose to discard conversation")
                    dismiss()
                }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Would you like to save this conversation?")
            }
        }
    }
    
    // MARK: - Assistant Header
    private var assistantHeader: some View {
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
                    .scaleEffect(scale)
            )
            .onChange(of: assistantState) { newState in
                withAnimation(newState.animation) {
                    switch newState {
                    case .idle:
                        isGlowing = true
                        rotation = 360.0
                        scale = 1.0
                    case .thinking:
                        isGlowing = true
                        rotation = 0.0
                        scale = 0.8
                    case .answering:
                        isGlowing = false
                        rotation = 0.0
                        scale = 1.2
                    }
                }
                
                // Reset to idle after answering
                if newState == .answering {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            assistantState = .idle
                        }
                    }
                }
            }
    }
    
    // MARK: - Artwork Preview
    private func artworkPreview(_ image: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reviewing:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Input Area
    private var inputArea: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                TextField("Ask me anything about art...", text: $inputText)
                    .textFieldStyle(.plain)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Button {
                    sendMessage(inputText)
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.purple)
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Helper Methods
    private func sendMessage(_ content: String) {
        // Add user message
        messages.append(AIMessage(content: content, isUser: true))
        inputText = ""
        
        // Simulate AI response
        assistantState = .thinking
        
        // TODO: Replace with actual AI call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            assistantState = .answering
            messages.append(AIMessage(
                content: "This is a simulated AI response. Replace with actual AI integration.",
                isUser: false
            ))
        }
        
        logger.debug("Sent message: \(content)")
    }
} 