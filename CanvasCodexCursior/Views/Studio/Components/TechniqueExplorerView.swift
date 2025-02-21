import SwiftUI
import os.log

// MARK: - Models
enum LearningFormat: String, CaseIterable {
    case quickTip = "Quick Tip"
    case practice = "Practice Exercise"
    case deepDive = "Deep Dive"
    case course = "Mini Course"
    
    var icon: String {
        switch self {
        case .quickTip: return "clock.fill"
        case .practice: return "book.fill"
        case .deepDive: return "books.vertical.fill"
        case .course: return "graduationcap.fill"
        }
    }
    
    var timeEstimate: String {
        switch self {
        case .quickTip: return "2-3 min read"
        case .practice: return "10-15 min"
        case .deepDive: return "30+ min"
        case .course: return "Multi-part"
        }
    }
}

enum TechniqueCategory: String, CaseIterable {
    case fundamentals = "Fundamentals"
    case mediums = "By Medium"
    case subjects = "By Subject"
    case effects = "Special Effects"
    
    var topics: [String] {
        switch self {
        case .fundamentals:
            return ["Forms & Shapes", "Perspective", "Light & Shadow", "Color Theory", "Composition"]
        case .mediums:
            return ["Watercolor", "Oil Painting", "Digital", "Sketching", "Acrylic"]
        case .subjects:
            return ["Figure Drawing", "Landscapes", "Still Life", "Portraits", "Animals"]
        case .effects:
            return ["Textures", "Atmosphere", "Reflections", "Transparency", "Metallic"]
        }
    }
    
    var icon: String {
        switch self {
        case .fundamentals: return "square.3.stack.3d"
        case .mediums: return "paintpalette.fill"
        case .subjects: return "photo.fill"
        case .effects: return "sparkles"
        }
    }
}

// MARK: - Technique Explorer View
struct TechniqueExplorerView: View {
    // Debug logging
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.canvascodex.app",
        category: "TechniqueExplorer"
    )
    
    @State private var selectedFormat: LearningFormat?
    @State private var searchText = ""
    @State private var showingChatSheet = false
    
    private var canGenerate: Bool {
        selectedFormat != nil && !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Learning Format Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose Learning Format")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(LearningFormat.allCases, id: \.self) { format in
                                FormatCard(
                                    format: format,
                                    isSelected: selectedFormat == format,
                                    action: { selectedFormat = format }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Search Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("What would you like to learn?")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .frame(width: 24)
                        
                        CustomTextField(
                            text: $searchText,
                            placeholder: "e.g., oil paint mixing, drawing eyes..."
                        )
                        .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36)
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .frame(width: 24)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 1)
                            .background(Color(.systemBackground))
                    )
                    .padding(.horizontal)
                    
                    // Generate Content Button
                    Button {
                        showingChatSheet = true
                    } label: {
                        Text("Generate Content")
                            .font(.headline)
                            .foregroundColor(canGenerate ? .white : .secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(canGenerate ? Color.purple : Color(.systemGray5))
                            )
                    }
                    .disabled(!canGenerate)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showingChatSheet) {
            if let format = selectedFormat {
                AIChatSheet(
                    initialPrompt: "Help me learn about \(searchText) through a \(format.rawValue.lowercased())",
                    artworkImage: nil,
                    artworkTitle: nil
                )
            }
        }
    }
}

// MARK: - Helper Views
struct FormatCard: View {
    let format: LearningFormat
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: format.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .purple : .secondary)
                
                Text(format.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(format.timeEstimate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 120, height: 120)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
} 