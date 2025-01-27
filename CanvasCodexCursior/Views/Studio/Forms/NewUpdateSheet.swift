import SwiftUI

struct NewUpdateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ArtworkViewModel()
    let project: ProjectEntity
    
    @State private var title = ""
    @State private var changes = ""
    @State private var todoNotes = ""
    @State private var isPublic = false
    @State private var showingScanner = false
    @State private var scannedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if let image = scannedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .frame(maxWidth: .infinity)
                    }
                    
                    Button {
                        showingScanner = true
                    } label: {
                        if scannedImage == nil {
                            Label("Add Progress Photo", systemImage: "camera")
                        } else {
                            Label("Retake Photo", systemImage: "arrow.triangle.2.circlepath")
                        }
                    }
                }
                
                Section("Update Details") {
                    TextField("Update Title", text: $title)
                    
                    TextEditor(text: $changes)
                        .frame(minHeight: 100)
                }
                
                Section("Todo List") {
                    TextEditor(text: $todoNotes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Toggle("Share to Public Feed", isOn: $isPublic)
                }
            }
            .navigationTitle("New Update")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveUpdate()
                    }
                    .disabled(title.isEmpty || scannedImage == nil)
                }
            }
            .sheet(isPresented: $showingScanner) {
                ScannerView(uploadType: .workInProgress) { form in
                    if case .workInProgress(let image) = form {
                        scannedImage = image
                    }
                }
            }
        }
    }
    
    private func saveUpdate() {
        guard let image = scannedImage else { return }
        
        do {
            try viewModel.saveWorkInProgress(
                projectName: project.name ?? "",
                updateTitle: title,
                changes: changes,
                todoNotes: todoNotes,
                isPublic: isPublic,
                image: image
            )
            dismiss()
        } catch {
            // Handle error
        }
    }
} 