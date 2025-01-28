import SwiftUI

struct ProjectDetailView: View {
    let project: ProjectEntity
    @StateObject private var viewModel = ArtworkViewModel()
    @State private var selectedTab = 0
    @State private var showingNewUpdate = false
    @State private var showingEditProject = false
    @State private var showingReferenceScanner = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker
            Picker("Section", selection: $selectedTab) {
                Text("Progress").tag(0)
                Text("References").tag(1)
                Text("Notes").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            TabView(selection: $selectedTab) {
                // Progress Tab
                ProgressUpdatesView(
                    project: project,
                    showingNewUpdate: $showingNewUpdate
                )
                .tag(0)
                
                // References Tab
                ReferencesView(
                    project: project,
                    showingScanner: $showingReferenceScanner
                )
                .tag(1)
                
                // Notes Tab
                NotesView(project: project)
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle(project.name ?? "Project")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEditProject = true
                    } label: {
                        Label("Edit Project", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        // Add delete functionality
                    } label: {
                        Label("Delete Project", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditProject) {
            EditProjectSheet(project: project)
        }
    }
}

// MARK: - Supporting Views
struct ProgressUpdatesView: View {
    let project: ProjectEntity
    @Binding var showingNewUpdate: Bool
    @StateObject private var viewModel = ArtworkViewModel()
    @State private var selectedUpdate: ProjectUpdateEntity?
    
    var sortedUpdates: [ProjectUpdateEntity] {
        guard let updates = project.updates?.allObjects as? [ProjectUpdateEntity] else {
            return []
        }
        return updates.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Add Update Button
                Button {
                    showingNewUpdate = true
                } label: {
                    Label("New Update", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
                .padding()
                
                if sortedUpdates.isEmpty {
                    ContentUnavailableView(
                        "No Updates",
                        systemImage: "camera",
                        description: Text("Add your first progress update")
                    )
                } else {
                    // Current Update View
                    if let update = selectedUpdate ?? sortedUpdates.first {
                        UpdateDetailView(update: update)
                            .transition(.opacity)
                    }
                    
                    // Development Timeline
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Development Timeline")
                            .font(.headline)
                        
                        TimelineView(
                            updates: sortedUpdates,
                            selectedUpdate: $selectedUpdate
                        )
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingNewUpdate) {
            NewUpdateSheet(project: project)
        }
        .onChange(of: sortedUpdates) { newUpdates in
            // Reset selection to latest when new updates are added
            if !newUpdates.isEmpty {
                selectedUpdate = newUpdates.first
            }
        }
    }
}

struct ReferencesView: View {
    let project: ProjectEntity
    @Binding var showingScanner: Bool
    
    var references: [ReferenceEntity] {
        project.references?.allObjects as? [ReferenceEntity] ?? []
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Button {
                    showingScanner = true
                } label: {
                    Label("Add Reference", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
                .padding()
                
                if references.isEmpty {
                    ContentUnavailableView(
                        "No References",
                        systemImage: "photo",
                        description: Text("Add reference images to help guide your project")
                    )
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                        ForEach(references) { reference in
                            ReferenceImageView(reference: reference)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct NotesView: View {
    let project: ProjectEntity
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Project Info
                Group {
                    if let medium = project.medium, !medium.isEmpty {
                        DetailRow(label: "Medium", value: medium)
                    }
                    
                    if let skills = project.skills, !skills.isEmpty {
                        DetailRow(label: "Skills", value: skills)
                    }
                    
                    if let timeEstimate = project.timeEstimate {
                        DetailRow(label: "Time Estimate", value: timeEstimate)
                    }
                    
                    if let priority = project.priority {
                        DetailRow(label: "Priority", value: priority)
                    }
                }
                
                if let inspiration = project.inspiration, !inspiration.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Inspiration")
                            .font(.headline)
                        Text(inspiration)
                    }
                }
            }
            .padding()
        }
    }
}

// Add this helper view for picking images
struct ImagePicker: UIViewControllerRepresentable {
    let image: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image(image)
            } else {
                parent.image(nil)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.image(nil)
            picker.dismiss(animated: true)
        }
    }
}

// Add this helper view for updates
struct UpdateCard: View {
    let update: ProjectUpdateEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let fileName = update.imageFileName,
               let image = ImageManager.shared.loadImage(fileName: fileName, category: .projectUpdate) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(update.title ?? "Update")
                    .font(.headline)
                
                if let date = update.date {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if let changes = update.changes, !changes.isEmpty {
                    Text(changes)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
} 
