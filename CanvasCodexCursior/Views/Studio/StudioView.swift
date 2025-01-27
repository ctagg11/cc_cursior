import SwiftUI

struct StudioView: View {
    @StateObject private var viewModel = ArtworkViewModel()
    @State private var showingProjectCreation = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.projects.isEmpty {
                    ContentUnavailableView(
                        "No Projects",
                        systemImage: "paintpalette",
                        description: Text("Create a project to start tracking your works in progress")
                    )
                } else {
                    List(viewModel.projects) { project in
                        NavigationLink(destination: ProjectDetailView(project: project)) {
                            ProjectRow(project: project)
                        }
                    }
                }
            }
            .navigationTitle("Studio")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingProjectCreation = true
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .sheet(isPresented: $showingProjectCreation) {
                CreateProjectSheet()
            }
        }
        .onAppear {
            viewModel.loadProjects()
        }
    }
} 