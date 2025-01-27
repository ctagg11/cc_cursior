import SwiftUI

struct ScanningFlowView: View {
    @Environment(\.dismiss) private var dismiss
    let uploadType: UploadType
    let onImageCaptured: (UIImage) -> Void
    
    init(uploadType: UploadType, onImageCaptured: @escaping (UIImage) -> Void) {
        self.uploadType = uploadType
        self.onImageCaptured = onImageCaptured
    }
    
    var body: some View {
        ScannerView(
            uploadType: uploadType,
            onScan: { form in
                switch form {
                case .newArtwork(let image),
                     .workInProgress(let image):
                    dismiss()
                    onImageCaptured(image)
                }
            }
        )
    }
} 