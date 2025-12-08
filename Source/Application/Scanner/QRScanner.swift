import Foundation

@MainActor
final class QRScanner: ObservableObject {
    enum CaptureDeviceState: Equatable {
        case unowned
        case requestCameraAccess
        case cameraAccessRequired
        case cameraPreview
        case processing
        case result(Int)
        case processingError
    }
    
    @Published var captureDeviceState: CaptureDeviceState = .unowned
    private var codeWasCaptured: Bool = false
    
    init() {
        updateCaptureState(for: CapturePermission().status)
    }
}

extension QRScanner {
    func requestCameraAccess() {
        let permission = CapturePermission()
        permission.requestPermission { [weak self] status in
            self?.updateCaptureState(for: status)
        }
    }
    
    private func updateCaptureState(for status: CapturePermission.Status) {
        Task { @MainActor in
            switch status {
            case .granted: captureDeviceState = .cameraPreview
            case .restricted: captureDeviceState = .cameraAccessRequired
            case .undefined: captureDeviceState = .requestCameraAccess
            }
        }
    }
    
    func tryAgain() {
        codeWasCaptured = false
        captureDeviceState = .cameraPreview
    }
    
    @MainActor
    func process(code value: String) async {
        guard codeWasCaptured == false else {
            return
        }
        codeWasCaptured = true
        captureDeviceState = .processing
        
        Task { [weak self] in
            guard let self else {
                return
            }
            
            do {
                let points = try await self.sendQRCode(value)
                await MainActor.run {
                    self.captureDeviceState = .result(points)
                }
            } catch {
                await MainActor.run {
                    self.captureDeviceState = .processingError
                }
            }
        }
    }
}

// MARK: - Guest Mode 

extension QRScanner {
    private func sendQRCode(_ value: String) async throws -> Int {
        try? await Task.sleep(for: .seconds(2))
        return 100
    }
}
