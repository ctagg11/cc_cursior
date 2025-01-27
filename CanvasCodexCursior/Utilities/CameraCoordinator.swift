import SwiftUI
import WeScan
import AVFoundation

class CameraCoordinator: NSObject, ImageScannerControllerDelegate {
    var parent: ScannerView
    
    init(_ parent: ScannerView) {
        self.parent = parent
        super.init()
        print("📸 Coordinator initialized")
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        print("📸 Scanner finished with results")
        scanner.dismiss(animated: true) {
            print("📸 Scanner dismissed")
            DispatchQueue.main.async {
                print("📸 Preparing to show form for type: \(self.parent.uploadType)")
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
        print("📸 Scanner failed with error: \(error.localizedDescription)")
        scanner.dismiss(animated: true)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        print("📸 Scanner cancelled by user")
        if let session = scanner.value(forKey: "captureSession") as? AVCaptureSession {
            session.stopRunning()
            print("📸 Stopped camera session")
        }
        scanner.dismiss(animated: true)
    }
} 