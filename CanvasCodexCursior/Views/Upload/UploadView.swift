import SwiftUI
import WeScan

struct UploadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingScanner = false
    @State private var uploadType: UploadType?
    @State private var activeForm: UploadForm?
    @State private var showingUploadOptions = false
    @State private var showingNewArtworkForm = false
    @State private var identifiableImage: IdentifiableImage?
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Main upload button - 44pt minimum touch target
                    Button(action: { showingUploadOptions = true }) {
                        VStack(spacing: 16) {
                            Image(systemName: "plus.viewfinder")
                                .font(.system(size: 44))
                            Text("Add Artwork")
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
            .sheet(isPresented: $showingUploadOptions) {
                UploadOptionsSheet(
                    isPresented: $showingUploadOptions,
                    uploadType: $uploadType,
                    showingScanner: $showingScanner
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
            .sheet(item: $activeForm) { form in
                switch form {
                case .workInProgress(let image):
                    WorkInProgressForm(scannedImage: image) {
                        activeForm = nil
                        selectedTab = 2
                    }
                case .newArtwork:
                    EmptyView()
                }
            }
            .fullScreenCover(item: $identifiableImage) { wrapper in
                NewArtworkForm(image: wrapper.image) {
                    identifiableImage = nil
                    selectedTab = 1
                }
            }
        }
    }
    
    private func handleCapturedImage(type: UploadType, image: UIImage) {
        switch type {
        case .newArtwork:
            identifiableImage = IdentifiableImage(image: image)
        case .workInProgress:
            activeForm = .workInProgress(image)
        }
    }
    
    private func showNewArtworkForm(with image: UIImage) {
        identifiableImage = IdentifiableImage(image: image)
    }
} 