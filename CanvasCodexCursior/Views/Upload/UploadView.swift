import SwiftUI
import WeScan
import UIKit

struct UploadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingScanner = false
    @State private var showingImagePicker = false
    @State private var showingOptions = false
    @State private var uploadType: UploadType?
    @State private var identifiableImage: IdentifiableImage?
    @State private var activeForm: UploadForm?
    @State private var selectedImage: UIImage?
    @State private var uploadSource: UploadSource = .scanner
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 32) {
                    // Main scan button
                    Button(action: {
                        uploadSource = .scanner
                        showingOptions = true
                    }) {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.viewfinder")  // Changed icon to better match scanning
                                .font(.system(size: 44))
                            Text("Scan Artwork")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(minWidth: 200, minHeight: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.indigo)
                        )
                    }
                    .shadow(radius: 5)
                    .padding(.top, 20)
                    // Divider text
                    Text("or")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                    
                    // Photo library button
                    Button(action: {
                        uploadSource = .photoLibrary
                        showingOptions = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 16))
                            Text("Choose from Photo Library")
                                .font(.subheadline)
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(minWidth: 200, minHeight: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.indigo.opacity(0.6))
                        )
                    }
                    .shadow(radius: 3)
                    
                    // Options description
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Upload Options")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        VStack(spacing: 20) {
                            UploadOptionRow(
                                icon: "paintpalette",
                                title: "New Artwork",
                                description: "Scan and upload a completed piece"
                            )
                            
                            UploadOptionRow(
                                icon: "clock",
                                title: "Work in Progress",
                                description: "Document your ongoing project"
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Upload")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingOptions) {
                UploadOptionsSheet(
                    isPresented: $showingOptions,
                    uploadType: $uploadType,
                    showingScanner: $showingScanner,
                    showingImagePicker: $showingImagePicker,
                    source: uploadSource
                )
            }
            .sheet(isPresented: $showingScanner) {
                if let type = uploadType {
                    ScanningFlowView(
                        uploadType: type,
                        onImageCaptured: { image in
                            handleCapturedImage(type: type, image: image)
                        }
                    )
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                NavigationStack {
                    ImagePicker(selectedImage: $selectedImage)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    showingImagePicker = false
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Add") {
                                    if let image = selectedImage {
                                        handleCapturedImage(type: uploadType ?? .newArtwork, image: image)
                                        selectedImage = nil
                                        showingImagePicker = false
                                    }
                                }
                                .disabled(selectedImage == nil)
                            }
                        }
                }
            }
            .sheet(item: $activeForm) { form in
                Group {
                    let _ = print("📝 Showing form: \(String(describing: form))")
                    switch form {
                    case .workInProgress(let image):
                        let _ = print("🏗️ Showing WorkInProgressForm")
                        WorkInProgressForm(image: image)
                    case .newArtwork(let image):
                        let _ = print("�� Showing NewArtworkForm")
                        NewArtworkForm(image: image) {
                            self.identifiableImage = nil
                            selectedTab = 1
                        }
                    }
                }
            }
            .fullScreenCover(item: $identifiableImage) { wrapper in
                let _ = print("🖼️ Showing fullscreen NewArtworkForm")
                NewArtworkForm(image: wrapper.image) {
                    self.identifiableImage = nil
                    selectedTab = 1
                }
            }
        }
    }
    
    private func handleCapturedImage(type: UploadType, image: UIImage) {
        print("🎯 Handling captured image for type: \(type)")
        
        switch type {
        case .newArtwork:
            print("🎨 Setting identifiableImage")
            identifiableImage = IdentifiableImage(image: image)
        case .workInProgress:
            print("🏗️ Setting activeForm")
            activeForm = .workInProgress(image)
        }
        
        print("📊 Updated state - activeForm: \(String(describing: activeForm)), identifiableImage: \(String(describing: identifiableImage))")
    }
    
    private func showNewArtworkForm(with image: UIImage) {
        identifiableImage = IdentifiableImage(image: image)
    }
}

#Preview("Upload View") {
    UploadView(selectedTab: .constant(2))
}

#Preview("Upload View - Dark Mode") {
    UploadView(selectedTab: .constant(2))
        .preferredColorScheme(.dark)
}

#Preview("Upload View - Compact") {
    UploadView(selectedTab: .constant(2))
        .previewDisplayName("Compact")
        .previewLayout(.sizeThatFits)
} 
