import SwiftUI

struct EditProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = ArtworkViewModel()
    let project: ProjectEntity
    
    @State private var formData: ProjectFormData
    
    init(project: ProjectEntity) {
        self.project = project
        _formData = State(initialValue: ProjectFormData(
            name: project.name ?? "",
            medium: project.medium ?? "",
            startDate: project.startDate ?? Date(),
            inspiration: project.inspiration ?? "",
            skills: project.skills ?? "",
            timeEstimate: TimeEstimate(rawValue: project.timeEstimate ?? "") ?? .singleSession,
            difficultyLevel: project.difficultyLevel != nil ? DifficultyLevel(rawValue: project.difficultyLevel ?? "") ?? .moderate : .moderate
        ))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Project Name", text: $formData.name)
                    TextField("Medium", text: $formData.medium)
                    DatePicker("Start Date", selection: $formData.startDate, displayedComponents: .date)
                }
                
                Section("Details") {
                    Picker("Time Estimate", selection: $formData.timeEstimate) {
                        ForEach(TimeEstimate.allCases, id: \.self) { estimate in
                            Text(estimate.description).tag(estimate)
                        }
                    }
                    
                    Picker("Difficulty Level", selection: $formData.difficultyLevel) {
                        ForEach(DifficultyLevel.allCases, id: \.self) { level in
                            Text(level.description).tag(level)
                        }
                    }
                }
                
                Section("Notes") {
                    TextField("Skills to Practice", text: $formData.skills)
                    TextEditor(text: $formData.inspiration)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(formData.name.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        project.name = formData.name
        project.medium = formData.medium
        project.startDate = formData.startDate
        project.inspiration = formData.inspiration
        project.skills = formData.skills
        project.timeEstimate = formData.timeEstimate.rawValue
        project.difficultyLevel = formData.difficultyLevel.rawValue  // Temporarily store in priority field
        
        try? viewContext.save()
        dismiss()
    }
}
