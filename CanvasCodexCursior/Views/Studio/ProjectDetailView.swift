import SwiftUI
import CoreData
import UIKit

struct ProjectDetailView: View {
    let project: ProjectEntity
    @StateObject private var viewModel = ProjectViewModel()
    @State private var selectedTab = 0
    @State private var showingNewUpdate = false
    @State private var showingEditProject = false
    @State private var showingReferenceScanner = false
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false
    @State private var showingCompletionConfirmation = false
    @State private var showingNoUpdatesAlert = false
    @State private var showingNewArtworkForm = false
    @State private var selectedUpdate: ProjectUpdateEntity?
    
    // Add observation of the project's objectWillChange
    @State private var projectObserver: Any?
    
    init(project: ProjectEntity) {
        self.project = project
        // Initialize the observer
        self._projectObserver = State(initialValue: NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextObjectsDidChange,
            object: project.managedObjectContext,
            queue: .main
        ) { _ in
            // Force view update when context changes
            project.objectWillChange.send()
        })
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name ?? "Untitled Project")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                
                HStack {
                    if let startDate = project.startDate {
                        Text("Started \(dateFormatter.string(from: startDate))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Status Indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(project.isCompleted ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)
                        Text(project.isCompleted ? "Completed" : "In Progress")
                            .font(.subheadline)
                            .foregroundStyle(project.isCompleted ? Color.green : Color.orange)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Tab Picker
            Picker("Section", selection: $selectedTab) {
                Text("Progress").tag(0)
                Text("Resources").tag(1)
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
        .navigationTitle("Work in Progress")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEditProject = true
                    } label: {
                        Label("Edit Project", systemImage: "pencil")
                    }
                    
                    if !project.isCompleted {
                        Button {
                            // Check if there are any updates before allowing completion
                            if let updates = project.updates?.allObjects as? [ProjectUpdateEntity],
                               !updates.isEmpty {
                                showingCompletionConfirmation = true
                            } else {
                                showingNoUpdatesAlert = true
                            }
                        } label: {
                            Label("Mark as Complete", systemImage: "checkmark.circle")
                        }
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
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
        .confirmationDialog(
            "Delete Project?",
            isPresented: $showingDeleteConfirmation,
            actions: {
                Button("Delete", role: .destructive) {
                    deleteProject()
                }
                Button("Cancel", role: .cancel) {}
            },
            message: {
                Text("This will permanently delete this project and all its updates. This action cannot be undone.")
            }
        )
        .confirmationDialog(
            "Complete Project?",
            isPresented: $showingCompletionConfirmation,
            actions: {
                Button("Complete and Create Artwork", role: .none) {
                    completeProject()
                }
                Button("Cancel", role: .cancel) {}
            },
            message: {
                Text("This will mark the project as complete and create a new artwork entry from your latest progress update.")
            }
        )
        .alert("No Updates Available", isPresented: $showingNoUpdatesAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please add at least one progress update before completing the project.")
        }
        .sheet(isPresented: $showingNewArtworkForm) {
            if let update = selectedUpdate,
               let imageFileName = update.imageFileName,
               let image = ImageManager.shared.loadImage(fileName: imageFileName, category: .projectUpdate) {
                NewArtworkForm(image: image) {
                    // Handle completion
                }
            }
        }
    }
    
    private func deleteProject() {
        // Delete all updates
        if let updates = project.updates?.allObjects as? [ProjectUpdateEntity] {
            for update in updates {
                // Delete associated image file if it exists
                if let fileName = update.imageFileName {
                    ImageManager.shared.deleteImage(fileName: fileName, category: .projectUpdate)
                }
                viewContext.delete(update)
            }
        }
        
        // Delete all references
        if let references = project.references?.allObjects as? [ReferenceEntity] {
            for reference in references {
                // Delete associated image file if it exists
                if let fileName = reference.imageFileName {
                    ImageManager.shared.deleteImage(fileName: fileName, category: .reference)
                }
                viewContext.delete(reference)
            }
        }
        
        // Delete the project itself
        viewContext.delete(project)
        
        // Save changes
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error deleting project: \(error)")
        }
    }
    
    private func completeProject() {
        // Get the most recent update
        if let updates = project.updates?.allObjects as? [ProjectUpdateEntity],
           let latestUpdate = updates.sorted(by: { ($0.date ?? Date()) > ($1.date ?? Date()) }).first,
           let imageFileName = latestUpdate.imageFileName,
           let image = ImageManager.shared.loadImage(fileName: imageFileName, category: .projectUpdate) {
            
            // Set the project as completed
            project.isCompleted = true
            try? viewContext.save()
            
            // Store the latest update for the artwork form
            selectedUpdate = latestUpdate
            
            // Show the new artwork form
            showingNewArtworkForm = true
        }
    }
}

// MARK: - Supporting Views
struct ProgressUpdatesView: View {
    let project: ProjectEntity
    @Binding var showingNewUpdate: Bool
    @StateObject private var viewModel = ProjectViewModel()
    @State private var selectedUpdate: ProjectUpdateEntity?
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingDeleteConfirmation = false
    @State private var updateToDelete: ProjectUpdateEntity?
    
    // Use FetchRequest for automatic updates
    @FetchRequest private var updates: FetchedResults<ProjectUpdateEntity>
    
    init(project: ProjectEntity, showingNewUpdate: Binding<Bool>) {
        self.project = project
        self._showingNewUpdate = showingNewUpdate
        
        // Initialize the fetch request
        let request = NSFetchRequest<ProjectUpdateEntity>(entityName: "ProjectUpdateEntity")
        request.predicate = NSPredicate(format: "project == %@", project)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ProjectUpdateEntity.date, ascending: false)]
        self._updates = FetchRequest(fetchRequest: request)
    }
    
    var sortedUpdates: [ProjectUpdateEntity] {
        Array(updates)
    }
    
    private func deleteUpdate(_ update: ProjectUpdateEntity) {
        // Delete associated image file if it exists
        if let fileName = update.imageFileName {
            ImageManager.shared.deleteImage(fileName: fileName, category: .projectUpdate)
        }
        
        // Remove from Core Data
        viewContext.delete(update)
        
        // If this was the selected update, select the next one
        if update == selectedUpdate {
            selectedUpdate = sortedUpdates.first
        }
        
        // Save changes
        do {
            try viewContext.save()
        } catch {
            print("Error deleting update: \(error)")
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    if sortedUpdates.isEmpty {
                        ContentUnavailableView(
                            "No Updates",
                            systemImage: "camera",
                            description: Text("Add your first progress update")
                        )
                        .padding(.top, 40)
                    } else {
                        // Current Update View
                        if let update = selectedUpdate ?? sortedUpdates.first {
                            UpdateDetailView(update: update)
                                .transition(.opacity)
                                .toolbar {
                                    ToolbarItem(placement: .primaryAction) {
                                        Button(role: .destructive) {
                                            updateToDelete = update
                                            showingDeleteConfirmation = true
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }
                                }
                        }
                        
                        // Development Timeline
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Development Timeline")
                                .font(.headline)
                            
                            TimelineView(
                                updates: sortedUpdates,
                                selectedUpdate: $selectedUpdate,
                                onDelete: { update in
                                    updateToDelete = update
                                    showingDeleteConfirmation = true
                                }
                            )
                        }
                    }
                }
                .padding()
                .padding(.bottom, 80) // Add padding for the button
            }
            
            // New Update Button
            Button {
                showingNewUpdate = true
            } label: {
                Label("New Update", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding()
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
            )
        }
        .sheet(isPresented: $showingNewUpdate) {
            NewUpdateSheet(project: project)
        }
        .onChange(of: sortedUpdates) { oldValue, newValue in
            // Reset selection to latest when new updates are added
            if !newValue.isEmpty {
                selectedUpdate = newValue.first
            }
        }
        .confirmationDialog(
            "Delete Update?",
            isPresented: $showingDeleteConfirmation,
            actions: {
                Button("Delete", role: .destructive) {
                    if let update = updateToDelete {
                        deleteUpdate(update)
                    }
                }
                Button("Cancel", role: .cancel) {}
            },
            message: {
                Text("This will permanently delete this update. This action cannot be undone.")
            }
        )
    }
}

struct ReferencesView: View {
    let project: ProjectEntity
    @Binding var showingScanner: Bool
    @State private var currentReferenceIndex = 0
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingDeleteConfirmation = false
    @State private var referenceToDelete: ReferenceEntity?
    
    // Use FetchRequest for automatic updates
    @FetchRequest private var references: FetchedResults<ReferenceEntity>
    
    init(project: ProjectEntity, showingScanner: Binding<Bool>) {
        self.project = project
        self._showingScanner = showingScanner
        
        // Initialize the fetch request
        let request = NSFetchRequest<ReferenceEntity>(entityName: "ReferenceEntity")
        request.predicate = NSPredicate(format: "project == %@", project)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ReferenceEntity.title, ascending: true)]
        self._references = FetchRequest(fetchRequest: request)
    }
    
    var sortedReferences: [ReferenceEntity] {
        Array(references)
    }
    
    private func deleteReference(_ reference: ReferenceEntity) {
        // Delete the image file
        if let fileName = reference.imageFileName {
            ImageManager.shared.deleteImage(fileName: fileName, category: .reference)
        }
        
        // Delete from Core Data
        viewContext.delete(reference)
        
        // Update current index if needed
        if currentReferenceIndex >= sortedReferences.count - 1 {
            currentReferenceIndex = max(0, sortedReferences.count - 2)
        }
        
        // Save changes
        try? viewContext.save()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 4) {
                    // Reference Images Section
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reference Images")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        if sortedReferences.isEmpty {
                            ContentUnavailableView(
                                "No References",
                                systemImage: "photo",
                                description: Text("Add reference images to help guide your project")
                            )
                            .padding(.top, 8)
                        } else {
                            // Reference Image Carousel
                            ZStack(alignment: .center) {
                                if !sortedReferences.isEmpty && currentReferenceIndex < sortedReferences.count {
                                    VStack(spacing: 2) {
                                        ReferenceImageView(reference: sortedReferences[currentReferenceIndex])
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: UIScreen.main.bounds.height * 0.5)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        // Title and Delete Button
                                        HStack {
                                            if let title = sortedReferences[currentReferenceIndex].title {
                                                Text(title)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Button(role: .destructive) {
                                                referenceToDelete = sortedReferences[currentReferenceIndex]
                                                showingDeleteConfirmation = true
                                            } label: {
                                                Image(systemName: "trash")
                                                    .foregroundStyle(.red)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // Navigation Arrows
                                HStack {
                                    Button {
                                        withAnimation {
                                            currentReferenceIndex = (currentReferenceIndex - 1 + sortedReferences.count) % sortedReferences.count
                                        }
                                    } label: {
                                        Image(systemName: "chevron.left.circle.fill")
                                            .font(.system(size: 30))
                                            .foregroundStyle(.white)
                                            .shadow(radius: 2)
                                    }
                                    .opacity(sortedReferences.count > 1 ? 1 : 0)
                                    
                                    Spacer()
                                    
                                    Button {
                                        withAnimation {
                                            currentReferenceIndex = (currentReferenceIndex + 1) % sortedReferences.count
                                        }
                                    } label: {
                                        Image(systemName: "chevron.right.circle.fill")
                                            .font(.system(size: 30))
                                            .foregroundStyle(.white)
                                            .shadow(radius: 2)
                                    }
                                    .opacity(sortedReferences.count > 1 ? 1 : 0)
                                }
                                .padding(.horizontal, 10)
                            }
                            
                            // Page Indicator
                            if sortedReferences.count > 1 {
                                HStack(spacing: 4) {
                                    ForEach(0..<sortedReferences.count, id: \.self) { index in
                                        Circle()
                                            .fill(index == currentReferenceIndex ? Color.blue : Color.gray.opacity(0.3))
                                            .frame(width: 6, height: 6)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 4)
                            }
                        }
                    }
                }
            }
            
            // Add Reference Button
            Button {
                showingScanner = true
            } label: {
                Label("Add Reference", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding()
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
            )
        }
        .confirmationDialog(
            "Delete Reference?",
            isPresented: $showingDeleteConfirmation,
            actions: {
                Button("Delete", role: .destructive) {
                    if let reference = referenceToDelete {
                        deleteReference(reference)
                    }
                }
                Button("Cancel", role: .cancel) {}
            },
            message: {
                Text("This will permanently delete this reference image.")
            }
        )
        .sheet(isPresented: $showingScanner) {
            ImagePicker(selectedImage: .init(get: { nil }, set: { image in
                if let image = image {
                    // Save the reference image
                    guard let fileName = ImageManager.shared.saveImage(image, category: .reference) else { return }
                    
                    let referenceEntity = ReferenceEntity(context: viewContext)
                    referenceEntity.id = UUID()
                    referenceEntity.imageFileName = fileName
                    referenceEntity.title = "Reference Image \(sortedReferences.count + 1)"
                    project.addToReferences(referenceEntity)
                    
                    do {
                        try viewContext.save()
                        // Force view update
                        currentReferenceIndex = sortedReferences.count - 1
                    } catch {
                        print("Error saving reference: \(error)")
                    }
                }
                showingScanner = false
            }))
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
