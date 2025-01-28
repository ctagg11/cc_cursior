import SwiftUI

struct TimelineView: View {
    let updates: [ProjectUpdateEntity]
    @Binding var selectedUpdate: ProjectUpdateEntity?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(updates) { update in
                    TimelineItem(
                        update: update,
                        isLatest: update == updates.first,
                        isSelected: update == selectedUpdate
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
    }
} 