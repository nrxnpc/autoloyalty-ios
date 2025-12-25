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
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: "qrcode.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundStyle(.blue, .tertiary)
                .symbolEffect(.bounce)
            
            VStack(spacing: 4) {
                Text("Validating QR code")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Please wait for completion")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder func makeResult(with earnedPoints: Int) -> some View {
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: "qrcode.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundStyle(.green, .tertiary)
            
            BalanceLabel(points: earnedPoints, operation: .income)
                .font(.headline)
            
            VStack(spacing: 4) {
                Text("Success!")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Points added to your balance")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 32)
        .onAppear {
            confettiCannonTrigger += earnedPoints
        }
    }
    
    @ViewBuilder func makeProcessingError() -> some View {
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: "qrcode.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundStyle(.red, .tertiary)
            
            VStack(spacing: 4) {
                Text("Invalid QR Code")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("This code cannot be used")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder func makeWasUsedError() -> some View {
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: "qrcode.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundStyle(.red, .tertiary)
            
            VStack(spacing: 4) {
                Text("Already Used")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("This code was already scanned")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    NavigationView {
        ZStack {
            VStack(alignment: .center, spacing: 16) {
                Image(systemName: "qrcode.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.green, .tertiary)
                
                BalanceLabel(points: 100, operation: .income)
                    .font(.headline)
                
                VStack(spacing: 4) {
                    Text("Success!")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Points added to your balance")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
        }
    }
}

