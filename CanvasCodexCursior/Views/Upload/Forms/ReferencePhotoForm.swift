import SwiftUI

struct ReferencePhotoForm: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var notes = ""
    @State private var selectedArtwork: UUID?
    let scannedImage: UIImage
    @StateObject private var viewModel = ArtworkViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Image(uiImage: scannedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .frame(maxWidth: .infinity)
                }
                
                Section("Reference Details") {
                    FormTextField(
                        label: "Title",
                        placeholder: "Enter reference title",
                        text: $title
                    )
                    
                    // TODO: Add artwork picker
                    Picker("Link to Artwork", selection: $selectedArtwork) {
                        Text("None").tag(nil as UUID?)
                        // TODO: Add existing artworks
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Notes") {
                    FormTextEditor(
                        label: "Reference Notes",
                        text: $notes
                    )
                }
            }
            .navigationTitle("Reference Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveReference()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveReference() {
        do {
            try viewModel.saveReference(
                title: title,
                notes: notes,
                image: scannedImage,
                artworkId: selectedArtwork
            )
            dismiss()
        } catch {
            // Handle error
        }
    }
} 