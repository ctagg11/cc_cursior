import SwiftUI
import WeScan
import AVFoundation

class ScannerCoordinator: NSObject, ImageScannerControllerDelegate {
    var parent: ScannerView
    
    init(_ parent: ScannerView) {
        self.parent = parent
        super.init()
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        scanner.dismiss(animated: true) {
            DispatchQueue.main.async {
                switch self.parent.uploadType {
                case .newArtwork:
                    self.parent.onScan(.newArtwork(results.croppedScan.image))
                case .workInProgress:
                    self.parent.onScan(.workInProgress(results.croppedScan.image))
                }
            }
        }
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        scanner.dismiss(animated: true)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true)
    }
}

struct ScannerView: UIViewControllerRepresentable {
    let uploadType: UploadType
    let onScan: (UploadForm) -> Void
    
    init(uploadType: UploadType, onScan: @escaping (UploadForm) -> Void) {
        self.uploadType = uploadType
        self.onScan = onScan
    }
    
    func makeUIViewController(context: Context) -> ImageScannerController {
        let scanner = ImageScannerController()
        scanner.imageScannerDelegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: ImageScannerController, context: Context) {}
    
    func makeCoordinator() -> ScannerCoordinator {
        ScannerCoordinator(self)
    }
} 