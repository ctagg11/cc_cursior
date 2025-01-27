import SwiftUI

struct ProjectRow: View {
    let project: ProjectEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(project.name ?? "")
                .font(.headline)
            
            HStack {
                if let medium = project.medium, !medium.isEmpty {
                    Text(medium)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if let updates = project.updates?.allObjects as? [ProjectUpdateEntity] {
                    Text("\(updates.count) update\(updates.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
} 