import SwiftUI

struct UpdateRow: View {
    let update: ProjectUpdateEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(update.title ?? "")
                    .font(.headline)
                Spacer()
                Text(update.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let changes = update.changes, !changes.isEmpty {
                Text(changes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if let todoNotes = update.todoNotes, !todoNotes.isEmpty {
                Text("Todo:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(todoNotes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
} 