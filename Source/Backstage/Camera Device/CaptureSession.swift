@preconcurrency import AVFoundation
import Foundation

@MainActor
final class CaptureSession: ObservableObject {
    @Published var readyForUse = false
    @Published var detectedQRCode: String?
    
    let device = CaptureSessionDevice()
    
    init() {
        Task {
            await device.setQRDetectionHandler { [weak self] qrCode in
                Task { @MainActor in
                    self?.detectedQRCode = qrCode
                }
            }
        }
    }
    
    func prepareForUse() {
        Task {
            guard CapturePermission().status == .granted else { return }
            let running = await device.prepareForUse()
            await MainActor.run {
                readyForUse = running
            }
            await device.reset()
        }
    }

    func stopRunning() {
        Task {
            await device.stopRunning()
            await MainActor.run {
                readyForUse = false
                detectedQRCode = nil
            }
        }
    }
    
    func reset() {
        stopRunning()
        prepareForUse()
    }
}

actor CaptureSessionDevice {
    private let session = AVCaptureSession()
    private var sessionDelegate: CaptureSessionDelegate?
    private var qrDetectionHandler: (@Sendable (String) -> Void)?
    private var isStarting = false
    private var isStopping = false
    
    func setQRDetectionHandler(_ handler: @escaping @Sendable (String) -> Void) {
        qrDetectionHandler = handler
        sessionDelegate?.updateHandler(handler)
    }
    
    func getSession() -> AVCaptureSession {
        return session
    }
    
    func prepareForUse() async -> Bool {
        guard !isStarting else { return session.isRunning }
        isStopping = false
        isStarting = true
        
        defer { isStarting = false }
        
        try? await Task.sleep(for: .milliseconds(100))
        guard !isStopping else { return false }
        
        await configureSession()
        return session.isRunning
    }
    
    func reset() {
        sessionDelegate?.reset()
    }
    
    func stopRunning() async {
        guard !isStopping else { return }
        isStarting = false
        isStopping = true
        
        defer { isStopping = false }
        
        try? await Task.sleep(for: .milliseconds(50))
        guard !isStarting else { return }
        
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    private func configureSession() async {
        guard !session.isRunning else { return }
        
        session.beginConfiguration()
        
        if session.canSetSessionPreset(.medium) {
            session.sessionPreset = .medium
        } else {
            session.sessionPreset = .low
        }
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            
            if sessionDelegate == nil {
                sessionDelegate = CaptureSessionDelegate()
            }
            if let handler = qrDetectionHandler {
                sessionDelegate?.updateHandler(handler)
            }
            output.setMetadataObjectsDelegate(sessionDelegate, queue: DispatchQueue.global(qos: .default))
            output.metadataObjectTypes = [.qr]
        }
        
        session.commitConfiguration()
        session.startRunning()
    }
    
    deinit {
        if session.isRunning {
            session.stopRunning()
        }
    }
}

final class CaptureSessionDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    private var onQRDetected: (@Sendable (String) -> Void)?
    private var lastStringValue: String?
    
    func reset() {
        lastStringValue = nil
    }
    
    func updateHandler(_ handler: @escaping @Sendable (String) -> Void) {
        onQRDetected = handler
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }
        
        if let lastStringValue, lastStringValue == stringValue{
            return
        }
        
        lastStringValue = stringValue
        onQRDetected?(stringValue)
    }
}
