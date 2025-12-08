import SwiftUI

// MARK: - View Builders

extension QRScannerView {
    // MARK: - Capture Device
    
    @ViewBuilder func makeRequestCameraAccess() -> some View {
        VStack(spacing: 32) {
            MakeIcon(systemImage: "camera.viewfinder", size: .large)
                .foregroundStyle(.primary)
            MakeTitle("Allow application to access your camera")
            
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "qrcode.viewfinder")
                VStack(spacing: 8) {
                    Text("How you'll use this")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("To scan QR codes and take photos for your profile")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "gear")
                VStack(spacing: 8) {
                    Text("How these settings work")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("You can change this anytime in your device settings. Allowing access now ensures a seamless experience later.")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            MakeButton("Allow Camera Access") {
                scanner.requestCameraAccess()
            }
        }
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder func makeCameraAccessRequired() -> some View {
        VStack(spacing: 32) {
            MakeIcon(systemImage: "camera.viewfinder", size: .large)
                .foregroundStyle(.primary)
            MakeTitle("Camera Access Required")
            
            Text("To continue, please enable camera access for applicatoin in your device's settings")
                .font(.subheadline)
            
            MakeButton("Go to Settings") {
                router.openSettings()
            }
        }
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder func makeCameraPreview() -> some View {
        CaptureSessionPreview(captureSession: captureSession)
            .overlay {
                makeCameraOverlay()
            }
            .task { @MainActor in
                captureSession.prepareForUse()
            }
            .id("capture-preview")
    }
}
