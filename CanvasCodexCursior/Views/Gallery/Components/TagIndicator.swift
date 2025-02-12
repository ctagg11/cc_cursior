import SwiftUI

struct TagIndicator: View {
    let tag: ComponentTagEntity
    @State private var isShowingDetails = false
    
    private var color: Color {
        switch tag.type {
        case .subject:
            return .blue
        case .process:
            return .orange
        }
    }
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(color, lineWidth: 2)
                .frame(width: 24, height: 24)
            
            // Inner fill
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 20, height: 20)
            
            // Center dot
            Circle()
                .fill(color.opacity(0.8))
                .frame(width: 6, height: 6)
        }
        .position(x: tag.locationX, y: tag.locationY)
        .onTapGesture {
            isShowingDetails = true
        }
        .popover(isPresented: $isShowingDetails) {
            TagDetailsPopover(tag: tag)
        }
    }
}

struct TagDetailsPopover: View {
    let tag: ComponentTagEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: tag.type.icon)
                    .foregroundStyle(tag.type == .subject ? .blue : .orange)
                Text(tag.name ?? "")
                    .font(.headline)
            }
            
            // Ratings
            HStack {
                StarRating(
                    rating: Int(tag.rating1),
                    label: tag.type == .subject ? "Satisfaction" : "Effectiveness"
                )
                Divider()
                StarRating(
                    rating: Int(tag.rating2),
                    label: tag.type == .subject ? "Complexity" : "Difficulty"
                )
            }
            
            // Notes
            if let notes = tag.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Process Steps (if applicable)
            if tag.type == .process,
               let steps = tag.processSteps,
               !steps.isEmpty {
                Divider()
                Text("Process Steps")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(steps)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

struct StarRating: View {
    let rating: Int
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundStyle(index <= rating ? .yellow : .gray.opacity(0.3))
                }
            }
        }
    }
}

