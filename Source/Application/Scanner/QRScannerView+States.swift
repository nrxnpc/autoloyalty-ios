import SwiftUI
import SwiftUIComponents

// MARK: - View Builders

extension QRScannerView {
    // MARK: - Capture Device States
    
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
        }
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder func makeCameraPreview() -> some View {
        ZStack {
            if captureSession.readyForUse {
                CaptureSessionPreview(captureSession: captureSession)
                    .overlay {
                        Viewfinder()
                            .aspectRatio(1, contentMode: .fit)
                            .padding(.horizontal, 16)
                            .transition(.opacity)
                    }
                    .id("capture-preview")
            }
            
            Viewfinder()
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 16)
                .opacity(captureSession.readyForUse ? 1.0 : 0.0)
        }
        .animation(.smooth, value: captureSession.readyForUse)
    }
    
    // MARK: - Processing States
    
    @ViewBuilder func makeProcessing() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.icloud")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.secondary, .tertiary)
                .symbolEffect(.rotate)
                .padding(.horizontal, 64)
            
            Text("Processing...")
                .font(.title)
                .padding(.horizontal, 32)
        }
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder func makeResult(with earnedPoints: Int) -> some View {
        VStack(alignment: .center, spacing: 16) {
            BalanceLabel(points: earnedPoints)
                .font(.title)
            
            Text("Points successfully added to your balance!")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.horizontal, 32)
        .onAppear {
            confettiCannonTrigger += earnedPoints
        }
    }
    
    @ViewBuilder func makeProcessingError() -> some View {
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: "xmark.icloud")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.secondary, .tertiary)
                .padding(.horizontal, 64)
            
            Text("This code cannot be scanned. Please try scanning a different QR code")
                .font(.callout)
                .padding(.horizontal, 32)
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    NavigationView {
        QRScannerView()
    }
}

