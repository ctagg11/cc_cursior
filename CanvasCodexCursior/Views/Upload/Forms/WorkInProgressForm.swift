import SwiftUI

struct WorkInProgressForm: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ArtworkViewModel()
    @State private var projectName = ""
    @State private var updateTitle = ""
    @State private var changes = ""
    @State private var todoNotes = ""
    @State private var isPublic = false
    let scannedImage: UIImage
    let onComplete: () -> Void
    
    private func saveProject() {
        do {
            try viewModel.saveWorkInProgress(
                projectName: projectName,
                updateTitle: updateTitle,
                changes: changes,
                todoNotes: todoNotes,
                isPublic: isPublic,
                image: scannedImage
            )
            dismiss()
            onComplete()
        } catch {
            // Handle error
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Image(uiImage: scannedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .frame(maxWidth: .infinity)
                }
                
                Section("Project Details") {
                    FormTextField(
                        label: "Project Name",
                        placeholder: "Enter project name",
                        text: $projectName
                    )
                    
                    FormTextField(
                        label: "Update Title",
                        placeholder: "e.g., Initial Sketch, Color Base",
                        text: $updateTitle
                    )
                }
                
                Section("Progress Notes") {
                    FormTextEditor(
                        label: "What Changed?",
                        text: $changes
                    )
                    
                    FormTextEditor(
                        label: "Todo List",
                        text: $todoNotes
                    )
                }
                
                Section {
                    Toggle("Share to Public Feed", isOn: $isPublic)
                }
            }
            .navigationTitle("Work in Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProject()
                    }
                    .disabled(projectName.isEmpty || updateTitle.isEmpty)
                }
            }
        }
    }
} 