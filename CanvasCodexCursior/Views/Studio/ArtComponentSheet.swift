import SwiftUI

struct ArtComponentSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Component Details") {
                    Text("Coming Soon!")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Art Component")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ArtComponentSheet()
} 