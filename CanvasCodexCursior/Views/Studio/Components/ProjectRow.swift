import SwiftUI
import Foundation

struct ProjectRow: View {
    let project: ProjectEntity
    
    var body: some View {
        HStack(spacing: 16) {
            projectPreview
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name ?? "Untitled")
                    .font(.headline)
                
                HStack {
                    Text(project.medium ?? "No medium")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(lastActivityDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if let timeEstimate = project.timeEstimate {
                    Text(timeEstimate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var projectPreview: some View {
        Group {
            if let latestUpdate = project.updates?.allObjects.first as? ProjectUpdateEntity,
               let fileName = latestUpdate.imageFileName,
               let image = ImageManager.shared.loadImage(fileName: fileName, category: .projectUpdate) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "paintbrush.pointed")
                    .font(.title)
                    .foregroundStyle(AppTheme.Colors.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.secondarySystemBackground))
            }
        }
    }
    
    private var lastActivityDate: String {
        let date = project.lastActivityDate ?? project.startDate ?? Date()
        return date.formatted(.dateTime.day().month().year())
    }
} 