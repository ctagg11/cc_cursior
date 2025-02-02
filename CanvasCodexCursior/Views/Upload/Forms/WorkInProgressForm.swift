import SwiftUI

struct WorkInProgressForm: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ArtworkViewModel()
    let image: UIImage
    
    @State private var selectedProjectId: String = ""
    @State private var showingCreateProject = false
    @State private var showingNewUpdate = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                }
                
                Section("Choose Project") {
                    Picker("Project", selection: $selectedProjectId) {
                        Text("Select Project").tag("")
                        ForEach(viewModel.projects) { project in
                            Text(project.name ?? "").tag(project.id?.uuidString ?? "")
                        }
                        Divider()
                        Text("Create New Project").tag("new")
                    }
                    .onChange(of: selectedProjectId) { newValue in
                        if newValue == "new" {
                            showingCreateProject = true
                        } else if !newValue.isEmpty {
                            if let project = viewModel.projects.first(where: { $0.id?.uuidString == newValue }) {
                                showingNewUpdate = true
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add to Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCreateProject) {
                CreateProjectSheet(initialUpdate: InitialUpdate(image: image))
            }
            .sheet(isPresented: $showingNewUpdate) {
                if let project = viewModel.projects.first(where: { $0.id?.uuidString == selectedProjectId }) {
                    NewUpdateSheet(project: project, initialImage: image)
                }
            }
            .onAppear {
                viewModel.loadProjects()
            }
        }
    }
}

struct InitialUpdate {
    let image: UIImage
    var title: String = ""
    var changes: String = ""
    var todoNotes: String = ""
    var isPublic: Bool = false
}

#Preview {
    WorkInProgressForm(image: UIImage(named: "SampleArtwork_landscape")!)
} 