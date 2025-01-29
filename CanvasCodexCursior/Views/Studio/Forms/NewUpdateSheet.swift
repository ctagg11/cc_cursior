import SwiftUI

struct NewUpdateSheet: View {
    let project: ProjectEntity
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ArtworkViewModel()
    
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
                    AppTextField(
                        label: "Update Title",
                        placeholder: "What did you accomplish?",
                        icon: "pencil",
                        text: $title
                    )
                    
                    TextEditor(text: $changes)
                        .frame(height: 100)
                        .overlay(
                            Group {
                                if changes.isEmpty {
                                    Text("What progress did you make?")
                                        .foregroundStyle(.secondary)
                                        .padding(.leading, 4)
                                        .padding(.top, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                    
                    TextEditor(text: $todoNotes)
                        .frame(height: 100)
                        .overlay(
                            Group {
                                if todoNotes.isEmpty {
                                    Text("What's next? (optional)")
                                        .foregroundStyle(.secondary)
                                        .padding(.leading, 4)
                                        .padding(.top, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                Section {
                    if let image = scannedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                    
                    Button {
                        showingScanner = true
                    } label: {
                        Label(scannedImage == nil ? "Scan Progress Image" : "Rescan Image", 
                              systemImage: "camera")
                    }
                }
                
                Section {
                    Toggle("Share Publicly", isOn: $isPublic)
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
            print("Error saving update: \(error)")
        }
    }
} 