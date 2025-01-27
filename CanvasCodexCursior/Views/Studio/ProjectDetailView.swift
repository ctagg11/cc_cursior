import SwiftUI

struct ProjectDetailView: View {
    let project: ProjectEntity
    @StateObject private var viewModel = ArtworkViewModel()
    @State private var selectedTab = 0
    @State private var showingNewUpdate = false
    @State private var showingEditProject = false
    @State private var showingReferenceScanner = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker
            Picker("View", selection: $selectedTab) {
                Text("Progress").tag(0)
                Text("References").tag(1)
                Text("Notes").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Swipeable Content
            TabView(selection: $selectedTab) {
                ProgressUpdatesView(project: project, showingNewUpdate: $showingNewUpdate)
                    .tag(0)
                
                ReferencesView(project: project, showingScanner: $showingReferenceScanner)
                    .tag(1)
                
                ProjectNotesView(project: project)
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
                        // Handle delete
                    } label: {
                        Label("Delete Project", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .frame(width: 44, height: 44)
                }
            }
        }
        .sheet(isPresented: $showingNewUpdate) {
            NewUpdateSheet(project: project)
        }
        .sheet(isPresented: $showingEditProject) {
            EditProjectSheet(project: project)
        }
        .sheet(isPresented: $showingReferenceScanner) {
            ImagePicker(image: { image in
                if let image = image {
                    try? viewModel.addReference(to: project, image: image)
                }
                showingReferenceScanner = false
            })
        }
    }
}

struct ProgressUpdatesView: View {
    let project: ProjectEntity
    @Binding var showingNewUpdate: Bool
    @State private var selectedUpdate: ProjectUpdateEntity?
    
    var sortedUpdates: [ProjectUpdateEntity] {
        guard let updates = project.updates?.allObjects as? [ProjectUpdateEntity] else {
            return []
        }
        return updates.sorted {
            guard let date1 = $0.date, let date2 = $1.date else { return false }
            return date1 > date2
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current Update View
                if let update = selectedUpdate ?? sortedUpdates.first {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(update == sortedUpdates.first ? "Current State" : update.title ?? "")
                                .font(.headline)
                            
                            Spacer()
                            
                            if update == sortedUpdates.first {
                                Button {
                                    showingNewUpdate = true
                                } label: {
                                    Label("Update", systemImage: "camera")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        UpdateDetailView(update: update)
                    }
                }
                
                // Timeline
                VStack(alignment: .leading, spacing: 12) {
                    Text("Development Timeline")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(sortedUpdates) { update in
                                Button {
                                    withAnimation {
                                        selectedUpdate = update
                                    }
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        if let fileName = update.imageFileName,
                                           let image = ImageManager.shared.loadImage(fileName: fileName, category: .projectUpdate) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                        
                                        Text("Stage \(sortedUpdates.count - (sortedUpdates.firstIndex(of: update) ?? 0))")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .opacity(selectedUpdate == update ? 1 : 0.6)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Quick Actions - now just the complete button
                Button {
                    // Mark as complete
                } label: {
                    Text("Mark as Complete")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()
            }
        }
    }
}

struct ReferencesView: View {
    let project: ProjectEntity
    @Binding var showingScanner: Bool
    
    var body: some View {
        ScrollView {
            if let references = project.references?.allObjects as? [ReferenceEntity] {
                if references.isEmpty {
                    ContentUnavailableView(
                        "No References",
                        systemImage: "photo",
                        description: Text("Add reference photos for your project")
                    )
                    .padding(.top, 40)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                        ForEach(references, id: \.id) { reference in
                            ReferenceCard(reference: reference)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct ProjectNotesView: View {
    let project: ProjectEntity
    
    var body: some View {
        List {
            if let learningGoals = project.learningGoals, !learningGoals.isEmpty {
                Section("Learning Goals") {
                    Text(learningGoals)
                }
            }
            
            if let skills = project.skills, !skills.isEmpty {
                Section("Key Skills") {
                    Text(skills)
                }
            }
            
            if let inspiration = project.inspiration, !inspiration.isEmpty {
                Section("Inspiration") {
                    Text(inspiration)
                }
            }
            
            if let timeEstimate = project.timeEstimate {
                Section("Time Estimate") {
                    Text(timeEstimate)
                }
            }
            
            if let priority = project.priority {
                Section("Priority") {
                    Text(priority)
                }
            }
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