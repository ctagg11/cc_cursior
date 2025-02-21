import SwiftUI
import os.log

struct ArtworkPickerView: View {
    let category: QuickActionCategory
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSource: ArtworkSource = .gallery
    
    // Debug logging
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.canvascodex.app",
        category: "ArtworkPicker"
    )
    
    // Grid layout
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Source Picker
                Picker("Source", selection: $selectedSource) {
                    ForEach(ArtworkSource.allCases, id: \.self) { source in
                        Text(source.rawValue)
                            .tag(source)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Artwork Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(0..<9) { index in
                            ArtworkThumbnailView(index: index)
                                .onTapGesture {
                                    // Debug log
                                    logger.debug("Selected artwork at index: \(index)")
                                    handleArtworkSelection(index)
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Artwork")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Debug log
                logger.debug("ArtworkPickerView appeared with category: \(category.rawValue)")
            }
        }
    }
    
    private func handleArtworkSelection(_ index: Int) {
        // TODO: Handle artwork selection and pass back to parent view
        dismiss()
    }
}

// MARK: - ArtworkThumbnailView
struct ArtworkThumbnailView: View {
    let index: Int
    
    var body: some View {
        // Placeholder for artwork thumbnail
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            )
            .cornerRadius(8)
    }
} 