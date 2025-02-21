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

// Add this struct before AIChatSheet
struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartQuotesType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        textField.autocapitalizationType = .none
        
        // Set proper height constraints
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            self._text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
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
    @FocusState private var isInputFocused: Bool
    
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
                    .padding(.vertical, 8)
                
                // Chat Content
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Initial Context
                            if let image = artworkImage {
                                VStack(spacing: 16) {
                                    artworkPreview(image)
                                    
                                    if !initialPrompt.isEmpty {
                                        // Context Label instead of message bubble
                                        Text(formatInitialPrompt(initialPrompt))
                                            .font(.subheadline)
                                            .italic()
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            
                            // Messages
                            ForEach(messages) { message in
                                MessageBubbleView(message: message)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
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
                // Auto-focus the input field if it's just chat
                if artworkImage == nil {
                    isInputFocused = true
                }
                
                // Start with AI response if there's an initial prompt
                if !initialPrompt.isEmpty {
                    logger.debug("Starting analysis with prompt: \(initialPrompt)")
                    // Simulate AI response without showing the prompt as a message
                    DispatchQueue.main.async {
                        assistantState = .thinking
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            assistantState = .answering
                            messages.append(AIMessage(
                                content: "This is a simulated AI response. Replace with actual AI integration.",
                                isUser: false
                            ))
                        }
                    }
                }
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
    
    private func formatInitialPrompt(_ prompt: String) -> String {
        // Convert the prompt into a more natural context label
        if prompt.contains("detailed analysis") {
            let aspects = prompt.contains("composition") ? "Composition" :
                         prompt.contains("color") ? "Color & Light" :
                         prompt.contains("technique") ? "Technique" :
                         prompt.contains("style") ? "Style" : ""
            return "Analyzing \(aspects)..."
        } else if prompt.contains("quick overall assessment") {
            return "Conducting quick review..."
        } else if prompt.contains("work in progress") {
            if prompt.contains("current progress") {
                return "Evaluating current progress..."
            } else {
                return "Planning next steps..."
            }
        }
        return "Starting conversation..."
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
                CustomTextField(text: $inputText, placeholder: "Ask me anything about art...")
                    .frame(height: 36)
                    .padding(.horizontal)
                    .padding(.vertical, 6)
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
            .padding(.horizontal)
            .padding(.vertical, 8)
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