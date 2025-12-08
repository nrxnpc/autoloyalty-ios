import AVFoundation
import UIKit
import SwiftUI

struct CaptureSessionPreview: UIViewRepresentable {
    @ObservedObject var captureSession: CaptureSession
    private var session: AVCaptureSession { captureSession.session }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard captureSession.isSessionConfigured else {
            return
        }
        
        uiView.layer.sublayers?.removeAll {
            $0 is AVCaptureVideoPreviewLayer
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = uiView.bounds
        
        if let connection = previewLayer.connection {
            connection.videoRotationAngle = 90
        }
        
        uiView.layer.addSublayer(previewLayer)
    }
}
