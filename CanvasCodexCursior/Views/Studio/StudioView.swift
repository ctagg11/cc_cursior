import SwiftUI
import CoreData

struct StudioView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var sortOption = SortOption.lastActivity
    @State private var filterOption = FilterOption.all
    @State private var searchText = ""
    @State private var showingCreateSheet = false
    
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
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case active = "In Progress"
        case completed = "Completed"
        case oil = "Oil"
        case watercolor = "Watercolor"
        case acrylic = "Acrylic"
        case other = "Other"
        
        var predicate: NSPredicate? {
            switch self {
            case .all: return nil
            case .active: return NSPredicate(format: "isCompleted == NO")
            case .completed: return NSPredicate(format: "isCompleted == YES")
            case .oil: return NSPredicate(format: "medium CONTAINS[cd] 'oil'")
            case .watercolor: return NSPredicate(format: "medium CONTAINS[cd] 'watercolor'")
            case .acrylic: return NSPredicate(format: "medium CONTAINS[cd] 'acrylic'")
            case .other: return NSPredicate(format: "NOT (medium CONTAINS[cd] 'oil' OR medium CONTAINS[cd] 'watercolor' OR medium CONTAINS[cd] 'acrylic')")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(FilterOption.allCases, id: \.self) { filter in
                            FilterPill(title: filter.rawValue, 
                                     isSelected: filterOption == filter) {
                                filterOption = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Projects List
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
                                .swipeActions(edge: .leading) {
                                    Button {
                                        // Show quick update sheet
                                    } label: {
                                        Label("Update", systemImage: "square.and.pencil")
                                    }
                                    .tint(.green)
                                }
                            }
                        }
                    }
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
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
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
                CreateProjectSheet()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    private var projects: [ProjectEntity] {
        let request = ProjectEntity.fetchRequest()
        
        // Combine predicates
        var predicates: [NSPredicate] = []
        if let filterPredicate = filterOption.predicate {
            predicates.append(filterPredicate)
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