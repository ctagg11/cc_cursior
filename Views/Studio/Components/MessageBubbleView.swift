import SwiftUI

// MARK: - Message Bubble View
struct MessageBubbleView: View {
    let message: AIMessage
    
    private var backgroundColor: Color {
        message.isUser ? Color(.systemGray6) : Color.purple.opacity(0.1)
    }
    
    private var foregroundColor: Color {
        message.isUser ? .primary : .primary
    }
    
    private var alignment: Alignment {
        message.isUser ? .trailing : .leading
    }
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
                if let image = message.attachedImage {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Text(message.content)
                    .foregroundColor(foregroundColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(backgroundColor)
                    )
            }
            .frame(maxWidth: .infinity, alignment: alignment)
            
            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 4)
    }
} 