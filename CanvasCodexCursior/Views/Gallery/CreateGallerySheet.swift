import SwiftUI

struct CreateGallerySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var galleryName = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @FocusState private var isNameFieldFocused: Bool
    
    var onGalleryCreated: ((String) -> Void)?
    @StateObject private var viewModel = ArtworkViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Gallery Name", text: $galleryName)
                        .focused($isNameFieldFocused)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("Gallery Details")
                } footer: {
                    Text("Create a gallery to organize your artwork into collections")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                }
                
                if !viewModel.galleries.isEmpty {
                    Section("Existing Galleries") {
                        ForEach(viewModel.galleries) { gallery in
                            HStack {
                                Text(gallery.name ?? "")
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                if let artworks = gallery.artworks?.allObjects as? [ArtworkEntity] {
                                    Text("\(artworks.count) artwork\(artworks.count == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createGallery()
                    }
                    .fontWeight(.semibold)
                    .disabled(galleryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            viewModel.loadGalleries()
            isNameFieldFocused = true
        }
    }
    
    private func createGallery() {
        let trimmedName = galleryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            _ = try viewModel.createGallery(name: trimmedName)
            onGalleryCreated?(trimmedName)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

#Preview {
    CreateGallerySheet { _ in }
} 