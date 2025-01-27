import SwiftUI

struct EditProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ArtworkViewModel()
    let project: ProjectEntity
    
    @State private var projectData: ProjectFormData
    
    init(project: ProjectEntity) {
        self.project = project
        _projectData = State(initialValue: ProjectFormData(
            name: project.name ?? "",
            medium: project.medium ?? "",
            startDate: project.startDate ?? Date(),
            inspiration: project.inspiration ?? "",
            learningGoals: project.learningGoals ?? "",
            skills: project.skills ?? "",
            timeEstimate: TimeEstimate(rawValue: project.timeEstimate ?? "") ?? .singleSession,
            priority: ProjectPriority(rawValue: project.priority ?? "") ?? .medium
        ))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Project Details") {
                    TextField("Project Name", text: $projectData.name)
                    
                    Picker("Medium", selection: $projectData.medium) {
                        Text("Select Medium").tag("")
                        ForEach(CommonMediums.allCases, id: \.self) { medium in
                            Text(medium.rawValue).tag(medium.rawValue)
                        }
                    }
                    
                    DatePicker("Start Date", selection: $projectData.startDate, displayedComponents: .date)
                }
                
                Section("Learning Goals") {
                    TextEditor(text: $projectData.learningGoals)
                        .frame(minHeight: 100)
                    
                    TextField("Key Skills (comma-separated)", text: $projectData.skills)
                }
                
                Section("Project Planning") {
                    Picker("Estimated Time", selection: $projectData.timeEstimate) {
                        ForEach(TimeEstimate.allCases, id: \.self) { estimate in
                            Text(estimate.description).tag(estimate)
                        }
                    }
                    
                    Picker("Priority", selection: $projectData.priority) {
                        ForEach(ProjectPriority.allCases, id: \.self) { priority in
                            Text(priority.description).tag(priority)
                        }
                    }
                }
                
                Section("Inspiration") {
                    TextEditor(text: $projectData.inspiration)
                        .frame(minHeight: 100)
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
                        saveProject()
                    }
                    .disabled(projectData.name.isEmpty)
                }
            }
        }
    }
    
    private func saveProject() {
        do {
            try viewModel.updateProject(project, with: projectData)
            dismiss()
        } catch {
            // Handle error
        }
    }
} 