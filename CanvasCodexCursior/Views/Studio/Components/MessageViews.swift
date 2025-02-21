import SwiftUI
import os.log

// MARK: - MessageBubbleView
struct MessageBubbleView: View {
    let message: AIMessage
    
    // Debug logging
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.canvascodex.app",
        category: "MessageBubble"
    )
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // Message content
                Text(message.content)
                    .foregroundColor(message.isUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(message.isUser ? Color.blue : Color(.systemGray6))
                    )
                
                // Attached image if present
                if let image = message.attachedImage {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                }
                
                // Timestamp
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !message.isUser {
                Spacer()
            }
        }
        .onAppear {
            // Debug log
            logger.debug("Displaying message: \(message.content)")
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - MessageInputView
struct MessageInputView: View {
    @Binding var text: String
    let onSend: () -> Void
    
    // Debug logging
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.canvascodex.app",
        category: "MessageInput"
    )
    
    var body: some View {
        HStack(spacing: 12) {
            // Text input field
            TextField("Ask me anything about art...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 8)
            
            // Send button
            Button(action: {
                // Debug log
                logger.debug("Sending message: \(text)")
                onSend()
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray4))
                .opacity(0.5),
            alignment: .top
        )
    }
} 
