import SwiftUI
import CoreData
import UIKit
import os.log

// MARK: - Models
enum ReviewType: String, CaseIterable {
    case finished = "Review Finished Work"
    case inProgress = "Review Work in Progress"
    
    var icon: String {
        switch self {
        case .finished: return "checkmark.circle.fill"
        case .inProgress: return "clock.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .finished: return .green
        case .inProgress: return .orange
        }
    }
    
    var description: String {
        switch self {
        case .finished: return "Select from your galleries"
        case .inProgress: return "Select from studio projects"
        }
    }
}

enum AnalysisType: String {
    case quick = "Quick Review"
    case detailed = "Detailed Analysis"
    
    var description: String {
        switch self {
        case .quick: return "Get an overall assessment of your artwork"
        case .detailed: return "Deep dive into specific aspects of your work"
        }
    }
}

struct AnalysisAspect: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    var isSelected: Bool
    
    static let aspects = [
        AnalysisAspect(name: "Composition", icon: "square.3.stack.3d", isSelected: false),
        AnalysisAspect(name: "Color & Light", icon: "sun.max.fill", isSelected: false),
        AnalysisAspect(name: "Technique", icon: "paintbrush.fill", isSelected: false),
        AnalysisAspect(name: "Style", icon: "paintpalette.fill", isSelected: false)
    ]
}

// MARK: - Review Flow View
struct ArtworkReviewFlow: View {
    // Debug logging
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.canvascodex.app",
        category: "ArtworkReview"
    )
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedReviewType: ReviewType?
    @State private var selectedItem: Any? // Will store either ArtworkEntity or ProjectEntity
    @State private var selectedAnalysisType: AnalysisType?
    @State private var analysisAspects: [AnalysisAspect] = AnalysisAspect.aspects
    @State private var canProceed = false
    @Binding var shouldNavigateToChat: Bool
    
    // Fetch requests for artworks
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ArtworkEntity.createdAt, ascending: false)],
        predicate: nil
    ) private var finishedArtworks: FetchedResults<ArtworkEntity>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ProjectEntity.lastActivityDate, ascending: false)],
        predicate: NSPredicate(format: "isCompleted == NO")
    ) private var worksInProgress: FetchedResults<ProjectEntity>
    
    init(shouldNavigateToChat: Binding<Bool>) {
        self._shouldNavigateToChat = shouldNavigateToChat
    }
    
    private var canShowProceedButton: Bool {
        if selectedAnalysisType == nil {
            return false
        }
        if selectedAnalysisType == .quick {
            return selectedItem != nil
        }
        return selectedItem != nil && analysisAspects.contains(where: { $0.isSelected })
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Content Area
            VStack(spacing: 20) {
                // Step 1: Review Type Selection
                if selectedReviewType == nil {
                    reviewTypeSelection
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                }
                
                // Step 2: Artwork Selection
                else if selectedItem == nil {
                    artworkSelection
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                }
                
                // Step 3: Analysis Type Selection and Options
                else {
                    // Always show analysis type selection
                    analysisTypeSelection
                    
                    // Show detailed options only if detailed analysis is selected
                    if selectedAnalysisType == .detailed {
                        detailedAnalysisOptions
                    }
                }
            }
            
            Spacer()
            
            // Debug log for button state
            .onChange(of: canShowProceedButton) { newValue in
                logger.debug("Can show proceed button changed to: \(newValue)")
            }
            
            // Proceed Button (always visible but conditionally enabled)
            Button {
                // Generate appropriate prompt based on selections
                let prompt = generatePrompt()
                logger.debug("Generated prompt: \(prompt)")
                shouldNavigateToChat = true
            } label: {
                Text("Get Feedback")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canShowProceedButton ? Color.purple : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!canShowProceedButton)
        }
        .padding()
    }
    
    // Helper to generate the appropriate prompt
    private func generatePrompt() -> String {
        var prompt = ""
        if let reviewType = selectedReviewType {
            prompt += "Please review my \(reviewType == .finished ? "finished artwork" : "work in progress"). "
        }
        
        if let analysisType = selectedAnalysisType {
            if analysisType == .quick {
                prompt += "Provide a quick overall assessment. "
            } else {
                prompt += "Provide a detailed analysis focusing on: "
                let selectedAspects = analysisAspects.filter { $0.isSelected }
                prompt += selectedAspects.map { $0.name.lowercased() }.joined(separator: ", ")
                prompt += ". "
            }
        }
        
        return prompt
    }
    
    // MARK: - Step Views
    private var reviewTypeSelection: some View {
        VStack(spacing: 16) {
            Text("What would you like to review?")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(ReviewType.allCases, id: \.self) { type in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedReviewType = type
                    }
                } label: {
                    HStack {
                        Image(systemName: type.icon)
                            .font(.system(size: 20))
                            .foregroundColor(type.iconColor)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(type.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(type.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var artworkSelection: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedReviewType = nil
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                }
                
                Text("Select Artwork")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if let reviewType = selectedReviewType {
                if reviewType == .finished {
                    if finishedArtworks.isEmpty {
                        emptyStateView(for: reviewType)
                    } else {
                        artworkGrid(items: finishedArtworks) { artwork in
                            ArtworkItemView(artwork: artwork)
                        }
                    }
                } else {
                    if worksInProgress.isEmpty {
                        emptyStateView(for: reviewType)
                    } else {
                        artworkGrid(items: worksInProgress) { project in
                            ProjectItemView(project: project)
                        }
                    }
                }
            }
        }
    }
    
    private func emptyStateView(for reviewType: ReviewType) -> some View {
        VStack(spacing: 12) {
            Image(systemName: reviewType == .finished ? "checkmark.circle" : "clock")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text(reviewType == .finished ? "No finished artworks yet" : "No works in progress")
                .font(.headline)
            
            Text(reviewType == .finished ? "Add artwork to your gallery" : "Start a new project to track progress")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
    
    private func artworkGrid<T: Identifiable, Content: View>(
        items: FetchedResults<T>,
        @ViewBuilder content: @escaping (T) -> Content
    ) -> some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(items) { item in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedItem = item
                        }
                    } label: {
                        content(item)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple, lineWidth: 3)
                                    .opacity(selectedItem as? AnyObject === item as? AnyObject ? 1 : 0)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)
        }
    }
    
    private var analysisTypeSelection: some View {
        VStack(spacing: 16) {
            // Back button and title
            HStack {
                Button {
                    withAnimation {
                        selectedItem = nil
                        selectedAnalysisType = nil
                        canProceed = false
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                }
                
                Text("Choose Review Type")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Analysis type buttons
            ForEach([AnalysisType.quick, AnalysisType.detailed], id: \.self) { type in
                let isSelected = selectedAnalysisType == type
                let buttonBackground = RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple.opacity(0.1) : Color(.systemGray6))
                let buttonBorder = RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
                
                Button {
                    handleAnalysisTypeSelection(type)
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(type.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(isSelected ? .purple : .primary)
                        
                        Text(type.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(buttonBackground)
                    .overlay(buttonBorder)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func handleAnalysisTypeSelection(_ type: AnalysisType) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedAnalysisType == type {
                selectedAnalysisType = nil
                canProceed = false
            } else {
                selectedAnalysisType = type
                canProceed = type == .quick
                
                if type == .quick {
                    analysisAspects = analysisAspects.map { aspect in
                        var newAspect = aspect
                        newAspect.isSelected = false
                        return newAspect
                    }
                }
            }
            
            logger.debug("Selected analysis type: \(String(describing: type))")
        }
    }
    
    private var detailedAnalysisOptions: some View {
        VStack(spacing: 16) {
            Text("Select Areas to Analyze")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Choose one or more aspects")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(analysisAspects.indices, id: \.self) { index in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            analysisAspects[index].isSelected.toggle()
                            canProceed = analysisAspects.contains(where: { $0.isSelected })
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: analysisAspects[index].icon)
                                .font(.system(size: 24))
                            
                            Text(analysisAspects[index].name)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(analysisAspects[index].isSelected ? Color.purple.opacity(0.1) : Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(analysisAspects[index].isSelected ? Color.purple : Color.clear,
                                               lineWidth: 2)
                                )
                        )
                    }
                    .foregroundColor(analysisAspects[index].isSelected ? .purple : .primary)
                    .buttonStyle(.plain)
                }
            }
        }
        .transition(.move(edge: .leading))
    }
}

// MARK: - Helper Views
struct ArtworkItemView: View {
    let artwork: ArtworkEntity
    
    // Debug logging
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.canvascodex.app",
        category: "ArtworkItemView"
    )
    
    var body: some View {
        VStack {
            Group {
                if let imageFileName = artwork.imageFileName,
                   let uiImage = ImageManager.shared.loadImage(fileName: imageFileName, category: .artwork) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onAppear {
                            logger.debug("Successfully loaded artwork image")
                        }
                } else {
                    placeholderImage
                        .onAppear {
                            logger.debug("No image filename available for artwork: \(artwork.name ?? "unnamed")")
                        }
                }
            }
            
            Text(artwork.name ?? "Untitled Artwork")
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
    }
    
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5))
            .frame(width: 150, height: 150)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
            )
    }
}

struct ProjectItemView: View {
    let project: ProjectEntity
    
    // Debug logging
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.canvascodex.app",
        category: "ProjectItemView"
    )
    
    var body: some View {
        VStack {
            Group {
                if let latestUpdate = (project.updates?.allObjects as? [ProjectUpdateEntity])?
                    .sorted(by: { ($0.date ?? Date()) > ($1.date ?? Date()) })
                    .first {
                    loadUpdateImage(from: latestUpdate)
                } else {
                    placeholderImage
                        .onAppear {
                            logger.debug("No updates found for project: \(project.name ?? "unnamed")")
                        }
                }
            }
            
            Text(project.name ?? "Untitled Project")
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .onAppear {
            logger.debug("Loading project view for: \(project.name ?? "unnamed")")
        }
    }
    
    private func loadUpdateImage(from update: ProjectUpdateEntity) -> some View {
        Group {
            if let imageFileName = update.imageFileName,
               let uiImage = ImageManager.shared.loadImage(fileName: imageFileName, category: .projectUpdate) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onAppear {
                        logger.debug("Successfully loaded project image")
                    }
            } else {
                placeholderImage
                    .onAppear {
                        logger.debug("No image filename in latest update")
                    }
            }
        }
    }
    
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5))
            .frame(width: 150, height: 150)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
            )
    }
} 