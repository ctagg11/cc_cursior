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
            priority: ProjectPriority(rawValue: project.priority ?? "") ?? .medium
        ))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Project Details") {
                    TextField("Project Name", text: $formData.name)
                        .textInputAutocapitalization(.words)
                    
                    Picker("Medium", selection: $formData.medium) {
                        Text("Select Medium").tag("")
                        ForEach(CommonMediums.allCases, id: \.self) { medium in
                            Text(medium.rawValue).tag(medium.rawValue)
                        }
                    }
                    
                    DatePicker("Start Date", selection: $formData.startDate, displayedComponents: .date)
                }
                
                Section("Notes & Planning") {
                    TextEditor(text: $formData.inspiration)
                        .frame(minHeight: 100)
                        .overlay(
                            Group {
                                if formData.inspiration.isEmpty {
                                    Text("Add notes about your inspiration...")
                                        .foregroundStyle(.secondary)
                                        .padding(.leading, 4)
                                        .padding(.top, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                    
                    TextField("Skills (comma-separated)", text: $formData.skills)
                }
                
                Section("Project Planning") {
                    Picker("Estimated Time", selection: $formData.timeEstimate) {
                        ForEach(TimeEstimate.allCases, id: \.self) { estimate in
                            Text(estimate.description).tag(estimate)
                        }
                    }
                    
                    Picker("Priority", selection: $formData.priority) {
                        ForEach(ProjectPriority.allCases, id: \.self) { priority in
                            Text(priority.description).tag(priority)
                        }
                    }
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
                        save()
                    }
                    .disabled(formData.name.isEmpty)
                }
            }
        }
    }
    
    private func save() {
        do {
            try viewModel.updateProject(project, with: formData)
            dismiss()
        } catch {
            // Handle error
            print("Error updating project: \(error)")
        }
    }
} 
