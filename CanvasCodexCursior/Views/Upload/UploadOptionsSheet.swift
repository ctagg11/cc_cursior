import SwiftUI

struct UploadOptionsSheet: View {
    @Binding var isPresented: Bool
    @Binding var uploadType: UploadType?
    @Binding var showingScanner: Bool
    
    var body: some View {
        NavigationStack {
            List {
                Button {
                    uploadType = .newArtwork
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingScanner = true
                    }
                } label: {
                    UploadOptionRow(
                        icon: "paintpalette",
                        title: "New Artwork",
                        description: "Scan and upload a completed piece"
                    )
                }
                
                Button {
                    uploadType = .workInProgress
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingScanner = true
                    }
                } label: {
                    UploadOptionRow(
                        icon: "clock",
                        title: "Work in Progress",
                        description: "Document your ongoing project"
                    )
                }
            }
            .navigationTitle("Choose Upload Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
} 