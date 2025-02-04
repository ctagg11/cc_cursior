import SwiftUI
import CoreData

struct StudioView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var sortOption = SortOption.lastActivity
    @State private var showActiveOnly = false
    @State private var searchText = ""
    @State private var showingCreateSheet = false
    @State private var selectedSection = Section.projects
    
    enum Section {
        case projects
        case components
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
                // Section Picker
                Picker("Section", selection: $selectedSection) {
                    Text("Works in Progress").tag(Section.projects)
                    Text("Art Components").tag(Section.components)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                if selectedSection == .projects {
                    projectsContent
                } else {
                    componentsContent
                }
            }
            .navigationTitle("Studio")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Sort By", selection: $sortOption) {
                            Label("Last Activity", systemImage: "clock").tag(SortOption.lastActivity)
                            Label("Creation Date", systemImage: "calendar").tag(SortOption.creationDate)
                            Label("Name", systemImage: "textformat").tag(SortOption.name)
                        }
                        
                        Toggle("Show Active Only", isOn: $showActiveOnly)
                    } label: {
                        Label("Sort & Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search projects")
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