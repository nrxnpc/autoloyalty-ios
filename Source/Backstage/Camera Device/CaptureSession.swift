import AVFoundation
import Foundation

final class CaptureSession: ObservableObject, @unchecked Sendable {
    private(set) var session = AVCaptureSession()
    private var sessionDelegate: CaptureSessionDelegate!
    
    @Published var isSessionConfigured = false
    @Published var detectedQRCode: String?
    
    init() {
        sessionDelegate = CaptureSessionDelegate(captureSession: self)
    }
    
    deinit {
        if session.isRunning {
            session.stopRunning()
        }
    }
}

extension CaptureSession {
    @MainActor
    func prepareForUse() {
        guard !isSessionConfigured else { return }
        
        Task {
            await configureSession()
        }
    }
    
    private func configureSession() async {
        session.beginConfiguration()
        if session.canSetSessionPreset(.high) {
            session.sessionPreset = .high
        } else {
            session.sessionPreset = .medium
        }
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            fatalError()
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(sessionDelegate, queue: DispatchQueue.global(qos: .default))
            output.metadataObjectTypes = [.qr]
        }
        
        session.commitConfiguration()
        session.startRunning()
        
        await MainActor.run {
            isSessionConfigured = true
        }
    }
}

final class CaptureSessionDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    private weak var captureSession: CaptureSession?
    private var lastStringValue: String?
    
    init(captureSession: CaptureSession) {
        self.captureSession = captureSession
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject else { return }
        guard let stringValue = readableObject.stringValue else { return }
        guard lastStringValue != stringValue else { return }
        
        lastStringValue = stringValue
        
        Task { @MainActor [captureSession] in
            captureSession?.detectedQRCode = stringValue
        }
    }
}
