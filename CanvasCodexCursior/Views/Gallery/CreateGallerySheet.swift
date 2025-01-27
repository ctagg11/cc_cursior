import SwiftUI

struct CreateGallerySheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ArtworkViewModel()
    @State private var galleryName = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @FocusState private var isNameFieldFocused: Bool
    
    var onComplete: ((GalleryEntity) -> Void)?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    FormSection(
                        title: "Gallery Details",
                        description: "Create a gallery to organize your artwork into collections"
                    ) {
                        AppTextField(
                            label: "Name",
                            placeholder: "Enter gallery name",
                            text: $galleryName,
                            icon: "folder"
                        )
                        .focused($isNameFieldFocused)
                    }
                    
                    if !viewModel.galleries.isEmpty {
                        FormSection(title: "Existing Galleries") {
                            VStack(spacing: 1) {
                                ForEach(viewModel.galleries) { gallery in
                                    ListRow(
                                        title: gallery.name ?? "",
                                        subtitle: "\(gallery.artworks?.count ?? 0) artworks",
                                        icon: "photo.stack"
                                    )
                                }
                            }
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.vertical, 24)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("New Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createGallery()
                    }
                    .font(.body.bold())
                    .foregroundStyle(.blue)
                    .disabled(galleryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            viewModel.loadGalleries()
            isNameFieldFocused = true
        }
    }
    
    private func createGallery() {
        do {
            let gallery = try viewModel.createGallery(name: galleryName)
            onComplete?(gallery)
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