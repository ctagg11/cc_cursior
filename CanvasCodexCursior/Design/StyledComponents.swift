import SwiftUI

// MARK: - Typography
struct AppText: View {
    enum Style {
        case title, headline, body, caption
        case secondary
        
        var font: Font {
            switch self {
            case .title: return .title.bold()
            case .headline: return .headline
            case .body: return .body
            case .caption: return .caption
            case .secondary: return .subheadline
            }
        }
        
        var color: Color {
            switch self {
            case .secondary: return AppTheme.Colors.textSecondary
            default: return AppTheme.Colors.text
            }
        }
    }
    
    let text: String
    let style: Style
    
    var body: some View {
        Text(text)
            .font(style.font)
            .foregroundStyle(style.color)
    }
}

// MARK: - Form Components
struct FormSection: View {
    let title: String
    let description: String?
    let content: AnyView
    
    init(
        title: String,
        description: String? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.title = title
        self.description = description
        self.content = AnyView(content())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                AppText(text: title, style: .headline)
                
                if let description = description {
                    AppText(text: description, style: .secondary)
                }
            }
            
            content
                .cardStyle()
        }
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}

struct AppTextField: View {
    let label: String
    let placeholder: String
    let icon: String
    var isSecureField: Bool = false
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                
                if isSecureField {
                    SecureField(placeholder, text: $text)
                        .textContentType(.password)
                        .foregroundColor(.primary)
                } else {
                    TextField(placeholder, text: $text)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

struct AppButton: View {
    enum Style {
        case primary, secondary
        
        var background: Color {
            switch self {
            case .primary: return AppTheme.Colors.primary
            case .secondary: return .clear
            }
        }
        
        var foreground: Color {
            switch self {
            case .primary: return .white
            case .secondary: return AppTheme.Colors.primary
            }
        }
    }
    
    let title: String
    let style: Style
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.bold())
                .frame(maxWidth: .infinity)
                .padding()
                .background(style.background)
                .foregroundStyle(style.foreground)
                .cornerRadius(12)
        }
    }
}

// MARK: - List Components
struct ListRow: View {
    let title: String
    let subtitle: String?
    let icon: String?
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                AppText(text: title, style: .body)
                
                if let subtitle = subtitle {
                    AppText(text: subtitle, style: .secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white)
    }
} 
