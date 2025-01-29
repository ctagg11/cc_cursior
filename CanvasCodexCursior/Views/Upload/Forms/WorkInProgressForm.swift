import SwiftUI

struct WorkInProgressForm: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ArtworkViewModel()
    let image: UIImage
    
    @State private var projectName = ""
    @State private var updateTitle = ""
    @State private var changes = ""
    @State private var todoNotes = ""
    @State private var isPublic = false
    @State private var showingProjectCreation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Preview Section
                    FormSection(title: "Preview") {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Project Details
                    FormSection(
                        title: "Project Details",
                        description: "Add this update to an existing project or create a new one"
                    ) {
                        VStack(spacing: AppTheme.Spacing.md) {
                            AppTextField(
                                label: "Project Name",
                                placeholder: "Enter project name",
                                icon: "paintpalette",
                                text: $projectName
                            )
                            
                            AppTextField(
                                label: "Update Title",
                                placeholder: "What did you accomplish?",
                                icon: "pencil",
                                text: $updateTitle
                            )
                        }
                    }
                    
                    // Changes Section
                    FormSection(
                        title: "Progress Details",
                        description: "Document your progress and next steps"
                    ) {
                        VStack(spacing: AppTheme.Spacing.md) {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                AppText(text: "Changes Made", style: .caption)
                                TextEditor(text: $changes)
                                    .frame(height: 100)
                                    .inputStyle()
                            }
                            
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                AppText(text: "Todo List", style: .caption)
                                TextEditor(text: $todoNotes)
                                    .frame(height: 100)
                                    .inputStyle()
                            }
                        }
                    }
                    
                    // Visibility Section
                    FormSection(
                        title: "Visibility",
                        description: "Choose who can see this update"
                    ) {
                        Toggle("Share to Public Feed", isOn: $isPublic)
                            .padding(.vertical, AppTheme.Spacing.xs)
                    }
                }
                .padding(.vertical, AppTheme.Spacing.lg)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("Work in Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProject()
                    }
                    .font(.body.bold())
                    .foregroundStyle(AppTheme.Colors.primary)
                    .disabled(projectName.isEmpty || updateTitle.isEmpty)
                }
            }
        }
        .preferredColorScheme(.light)
    }
    
    private func saveProject() {
        do {
            try viewModel.saveWorkInProgress(
                projectName: projectName,
                updateTitle: updateTitle,
                changes: changes,
                todoNotes: todoNotes,
                isPublic: isPublic,
                image: image
            )
            dismiss()
        } catch {
            // Handle error
        }
    }
} 