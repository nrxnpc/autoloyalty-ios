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
    
    func prepareForUse() async {
        let running = await device.prepareForUse()
        readyForUse = running
        await device.reset()
    }
    
    func stopRunning() async {
        await device.stopRunning()
        readyForUse = false
        detectedQRCode = nil
    }
    
    func reset() async {
        await stopRunning()
        await prepareForUse()
    }
}

actor CaptureSessionDevice {
    private let session = AVCaptureSession()
    private var sessionDelegate: CaptureSessionDelegate?
    private var currentTask: Task<Void, Never>?
    private var qrDetectionHandler: (@Sendable (String) -> Void)?
    
    func setQRDetectionHandler(_ handler: @escaping @Sendable (String) -> Void) {
        qrDetectionHandler = handler
        sessionDelegate?.updateHandler(handler)
    }
    
    func getSession() -> AVCaptureSession {
        return session
    }
    
    func prepareForUse() async -> Bool {
        currentTask?.cancel()
        
        currentTask = Task {
            try? await Task.sleep(for: .milliseconds(100))
            guard !Task.isCancelled else { return }
            await configureSession()
        }
        
        await currentTask?.value
        return session.isRunning
    }
    
    func reset() {
        sessionDelegate?.reset()
    }
    
    func stopRunning() async {
        currentTask?.cancel()
        
        currentTask = Task {
            try? await Task.sleep(for: .milliseconds(50))
            guard !Task.isCancelled else { return }
            
            if session.isRunning {
                session.stopRunning()
            }
        }
        
        await currentTask?.value
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
        currentTask?.cancel()
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
