import SwiftUI

struct CreateProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ArtworkViewModel()
    @State private var projectData = ProjectFormData()
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic Info Section
                Section("Project Details") {
                    TextField("Project Name", text: $projectData.name)
                        .textInputAutocapitalization(.words)
                    
                    Picker("Medium", selection: $projectData.medium) {
                        Text("Select Medium").tag("")
                        ForEach(CommonMediums.allCases, id: \.self) { medium in
                            Text(medium.rawValue).tag(medium.rawValue)
                        }
                    }
                    
                    DatePicker("Start Date", selection: $projectData.startDate, displayedComponents: .date)
                }
                
                // Reference & Inspiration Section
                Section("References & Inspiration") {
                    TextEditor(text: $projectData.inspiration)
                        .frame(minHeight: 100)
                    
                    // References Grid
                    if !projectData.references.isEmpty {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                            ForEach(projectData.references) { reference in
                                Image(uiImage: reference.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    
                    Button {
                        showingImagePicker = true
                    } label: {
                        Label("Add Reference", systemImage: "photo")
                    }
                }
                
                // Learning Goals Section
                Section("Learning Goals") {
                    TextEditor(text: $projectData.learningGoals)
                        .frame(minHeight: 100)
                    
                    TextField("Key Skills (comma-separated)", text: $projectData.skills)
                }
                
                // Project Planning Section
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
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        save()
                    }
                    .disabled(projectData.name.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker { image in
                    if let image = image {
                        projectData.references.append(ReferenceImage(image: image))
                    }
                }
            }
        }
    }
    
    private func save() {
        do {
            try viewModel.createProject(projectData)
            dismiss()
        } catch {
            // Handle error
        }
    }
} 