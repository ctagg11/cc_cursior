import SwiftUI
import UIKit

struct UploadOptionsSheet: View {
    @Binding var isPresented: Bool
    @Binding var uploadType: UploadType?
    @Binding var showingScanner: Bool
    @Binding var showingImagePicker: Bool
    let source: UploadSource
    
    var body: some View {
        NavigationStack {
            List {
                Button {
                    print("🎯 UploadOptionsSheet: Selected .newArtwork")
                    print("📸 Source: \(source)")
                    uploadType = .newArtwork
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("⏱️ Showing picker/scanner after delay")
                        switch source {
                        case .scanner:
                            print("📷 Showing scanner")
                            showingScanner = true
                        case .photoLibrary:
                            print("🖼️ Showing image picker")
                            showingImagePicker = true
                        }
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
                        switch source {
                        case .scanner:
                            showingScanner = true
                        case .photoLibrary:
                            showingImagePicker = true
                        }
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