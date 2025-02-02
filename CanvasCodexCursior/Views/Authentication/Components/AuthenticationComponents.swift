import SwiftUI

// Shared button styles for authentication
struct AuthButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case secondary
        case social
        
        var background: Color {
            switch self {
            case .primary: return .accentColor
            case .secondary: return .gray.opacity(0.1)
            case .social: return .white
            }
        }
        
        var foreground: Color {
            switch self {
            case .primary: return .white
            case .secondary, .social: return .primary
            }
        }
    }
    
    init(
        title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(style.background)
            .foregroundColor(style.foreground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: style == .social ? 1 : 0)
            )
        }
    }
}

// Shared text field for authentication
struct AuthTextField: View {
    let label: String
    let placeholder: String
    let icon: String
    let isSecureField: Bool
    @Binding var text: String
    
    init(
        label: String,
        placeholder: String,
        icon: String,
        isSecureField: Bool = false,
        text: Binding<String>
    ) {
        self.label = label
        self.placeholder = placeholder
        self.icon = icon
        self.isSecureField = isSecureField
        self._text = text
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Group {
                if isSecureField {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textFieldStyle(.roundedBorder)
        }
    }
}

// Shared header for authentication views
struct AuthHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "paintpalette")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title.bold())
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.bottom, 32)
    }
} 