import SwiftUI
import CoreData

// Remove the AI Assistant Models section and keep everything else
struct StudioView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var sortOption = SortOption.lastActivity
    @State private var searchText = ""
    @State private var showingCreateSheet = false
    @State private var selectedSection = Section.projects
    @State private var projectToDelete: ProjectEntity?
    @State private var showingDeleteConfirmation = false
    
    enum Section: String {
        case projects = "Works in Progress"
        case components = "AI Art Assistant"
    }
    
    enum SortOption: String {
        case lastActivity = "Last Update"
        case creationDate = "Start Date"
        case name = "Name"
        
        var descriptor: NSSortDescriptor {
            switch self {
            case .lastActivity:
                return NSSortDescriptor(keyPath: \ProjectEntity.lastActivityDate, ascending: false)
            case .creationDate:
                return NSSortDescriptor(keyPath: \ProjectEntity.startDate, ascending: false)
            case .name:
                return NSSortDescriptor(keyPath: \ProjectEntity.name, ascending: true)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header Section with Tabs
                VStack(spacing: 0) {
                    // Section Tabs
                    HStack(spacing: 0) {
                        ForEach([Section.projects, Section.components], id: \.self) { section in
                            Button {
                                selectedSection = section
                            } label: {
                                VStack(spacing: 4) {
                                    Text(section.rawValue)
                                        .font(.headline)
                                        .foregroundColor(selectedSection == section ? .primary : .secondary)
                                    
                                    // Underline indicator
                                    Rectangle()
                                        .fill(selectedSection == section ? Color.orange : Color.clear)
                                        .frame(height: 2)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Only show search and filters for Projects section
                    if selectedSection == .projects {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField("Search projects", text: $searchText)
                                .textFieldStyle(.plain)
                            
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        Divider()
                    }
                }
                .background(Color(.systemBackground))
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedSection)
                
                // Sort Control (moved outside the white background)
                if selectedSection == .projects {
                    HStack {
                        Spacer()
                        Menu {
                            Picker("Sort By", selection: $sortOption) {
                                Text("Name").tag(SortOption.name)
                                Text("Start Date").tag(SortOption.creationDate)
                                Text("Last Update").tag(SortOption.lastActivity)
                            }
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }
                
                // Content
                if selectedSection == .projects {
                    projectsContent
                } else {
                    componentsContent
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Studio")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                if selectedSection == .projects {
                    CreateProjectSheet()
                        .environment(\.managedObjectContext, viewContext)
                } else {
                    ArtComponentSheet()
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
        .alert("Delete Project?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let project = projectToDelete {
                    deleteProject(project)
                }
            }
        } message: {
            Text("This will permanently delete this project and its associated data.")
        }
    }
    
    private var projectsContent: some View {
        Group {
            if projects.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "No Projects" : "No Results",
                    systemImage: "paintpalette",
                    description: Text(searchText.isEmpty ? 
                        "Create a project to start tracking your works in progress" : 
                        "Try adjusting your search or filters")
                )
            } else {
                List {
                    ForEach(projects) { project in
                        NavigationLink(destination: ProjectDetailView(project: project)) {
                            HStack {
                                // Status Indicator
                                Circle()
                                    .fill(project.isCompleted ? Color.green : Color.orange)
                                    .frame(width: 8, height: 8)
                                
                                ProjectRow(project: project)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                projectToDelete = project
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                toggleProjectCompletion(project)
                            } label: {
                                Label(
                                    project.isCompleted ? "Mark Incomplete" : "Mark Complete",
                                    systemImage: project.isCompleted ? "xmark.circle" : "checkmark.circle"
                                )
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
        }
    }
    
    private var componentsContent: some View {
        AIArtAssistantView()
    }
    
    private var projects: [ProjectEntity] {
        let request = ProjectEntity.fetchRequest()
        
        // Combine predicates
        var predicates: [NSPredicate] = []
        
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        request.sortDescriptors = [sortOption.descriptor]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching projects: \(error)")
            return []
        }
    }
    
    private func deleteProject(_ project: ProjectEntity) {
        viewContext.delete(project)
        try? viewContext.save()
    }
    
    private func toggleProjectCompletion(_ project: ProjectEntity) {
        project.isCompleted.toggle()
        try? viewContext.save()
    }
} 