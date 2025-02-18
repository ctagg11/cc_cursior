import SwiftUI
import CoreData

struct StudioView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var sortOption = SortOption.lastActivity
    @State private var showActiveOnly = false
    @State private var searchText = ""
    @State private var showingCreateSheet = false
    @State private var selectedSection = Section.projects
    
    enum Section: String {
        case projects = "Works in Progress"
        case components = "Components"
    }
    
    enum SortOption {
        case lastActivity
        case creationDate
        case name
        
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
                                withAnimation {
                                    selectedSection = section
                                }
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
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField(
                            selectedSection == .projects ? "Search works" : "Search components",
                            text: $searchText
                        )
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
                .background(Color(.systemBackground))
                
                // Quick Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(
                            icon: "paintpalette",
                            title: "All",
                            isSelected: !showActiveOnly
                        ) {
                            showActiveOnly = false
                        }
                        
                        FilterChip(
                            icon: "clock",
                            title: "Active",
                            isSelected: showActiveOnly
                        ) {
                            showActiveOnly = true
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
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
                            ProjectRow(project: project)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteProject(project)
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
        ContentUnavailableView(
            "Coming Soon",
            systemImage: "square.stack.3d.up",
            description: Text("Art Components will help you organize reusable elements of your artwork")
        )
    }
    
    private var projects: [ProjectEntity] {
        let request = ProjectEntity.fetchRequest()
        
        // Combine predicates
        var predicates: [NSPredicate] = []
        
        if showActiveOnly {
            predicates.append(NSPredicate(format: "isCompleted == NO"))
        }
        
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

// Add this helper view for filter chips
struct FilterChip: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(title)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.orange.opacity(0.2) : Color(.systemGray6))
            .foregroundColor(isSelected ? .orange : .primary)
            .clipShape(Capsule())
        }
    }
} 