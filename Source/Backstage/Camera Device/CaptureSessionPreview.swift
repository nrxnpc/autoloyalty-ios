import AVFoundation
import UIKit
import SwiftUI

struct CaptureSessionPreview: UIViewRepresentable {
    @ObservedObject var captureSession: CaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        PreviewView()
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        if captureSession.readyForUse {
            Task {
                let session = await captureSession.device.getSession()
                await MainActor.run {
                    uiView.setupPreview(with: session)
                }
            }
        } else {
            uiView.removePreview()
        }
    }
}

class PreviewView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    func setupPreview(with session: AVCaptureSession) {
        guard previewLayer?.session !== session else {
            previewLayer?.frame = bounds
            return
        }
        
        removePreview()
        
        let newPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        newPreviewLayer.videoGravity = .resizeAspectFill
        newPreviewLayer.frame = bounds
        
        if let connection = newPreviewLayer.connection {
            connection.videoRotationAngle = 90
        }
        
        layer.addSublayer(newPreviewLayer)
        previewLayer = newPreviewLayer
    }
    
    func removePreview() {
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}
