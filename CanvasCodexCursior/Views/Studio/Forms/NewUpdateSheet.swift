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
    @State private var showingImagePicker = false
    
    init(project: ProjectEntity, initialImage: UIImage? = nil) {
        self.project = project
        self._scannedImage = State(initialValue: initialImage)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What did you accomplish?", text: $title)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
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
                        VStack(spacing: 8) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                            
                            Button(role: .destructive) {
                                scannedImage = nil
                            } label: {
                                Label("Remove Photo", systemImage: "trash")
                            }
                        }
                    } else {
                        VStack(spacing: 16) {
                            Button {
                                showingScanner = true
                            } label: {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.secondary)
                                    Text("Scan Progress Image")
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
                                .background(Color(uiColor: .systemBackground))
                            }
                            .buttonStyle(.plain)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(style: StrokeStyle(
                                        lineWidth: 1,
                                        dash: [6],
                                        dashPhase: 0
                                    ))
                                    .foregroundStyle(Color.gray.opacity(0.3))
                            )
                            .cornerRadius(8)
                            
                            Button {
                                showingImagePicker = true
                            } label: {
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.secondary)
                                    Text("Choose from Library")
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
                                .background(Color(uiColor: .systemBackground))
                            }
                            .buttonStyle(.plain)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(style: StrokeStyle(
                                        lineWidth: 1,
                                        dash: [6],
                                        dashPhase: 0
                                    ))
                                    .foregroundStyle(Color.gray.opacity(0.3))
                            )
                            .cornerRadius(8)
                        }
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
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $scannedImage)
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