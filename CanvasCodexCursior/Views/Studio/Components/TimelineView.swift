import SwiftUI

struct TimelineView: View {
    let updates: [ProjectUpdateEntity]
    @Binding var selectedUpdate: ProjectUpdateEntity?
    var onDelete: (ProjectUpdateEntity) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(updates) { update in
                    TimelineItem(
                        update: update,
                        isLatest: update == updates.first,
                        isSelected: update == selectedUpdate,
                        onDelete: { onDelete(update) }
                    )
                    .onTapGesture {
                        withAnimation {
                            selectedUpdate = update
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct TimelineItem: View {
    let update: ProjectUpdateEntity
    let isLatest: Bool
    let isSelected: Bool
    let onDelete: () -> Void
    @State private var showingDeleteButton = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let fileName = update.imageFileName,
                   let image = ImageManager.shared.loadImage(fileName: fileName, category: .projectUpdate) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                }
                
                if showingDeleteButton {
                    Button {
                        onDelete()
                    } label: {
                        Circle()
                            .fill(.red)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                    }
                    .offset(x: 6, y: -6)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                withAnimation(.spring(response: 0.3)) {
                    showingDeleteButton = true
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(update.title ?? "Update")
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    if isLatest {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }
                
                if let date = update.date {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: 120)
        .onTapGesture {
            if showingDeleteButton {
                withAnimation(.spring(response: 0.3)) {
                    showingDeleteButton = false
                }
            }
        }
    }
} 