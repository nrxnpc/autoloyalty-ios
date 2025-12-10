import SwiftUI
import SwiftUIComponents

// MARK: - View Builders

extension QRScannerView {
    // MARK: - Buttons
    
    @ViewBuilder func makeAllowCameraButton() -> some View {
        Button("Allow Camera Access") {
            scanner.requestCameraAccess()
        }
        .buttonStyle(PrimaryButtonStyle())
    }
    
    @ViewBuilder func makeSettingsButton() -> some View {
        Button {
            router.openSettings()
        } label: {
            HStack {
                Image(systemName: "gear")
                    .font(.callout)
                Text("Device Settings")
                    .font(.callout)
            }
        }
        .buttonStyle(PrimaryButtonStyle())
    }
    
    @ViewBuilder func makeTryAgainButton() -> some View {
        Button {
            Task {
                await captureSession.reset()
                await MainActor.run {
                    scanner.tryAgain()
                }
            }
        } label: {
            HStack {
                Image(systemName: "arrow.clockwise")
                    .font(.callout)
                Text("Try Again")
                    .font(.callout)
            }
        }
        .buttonStyle(StrokeButtonStyle())
    }
    
    @ViewBuilder func makeFinishButton() -> some View {
        Button("Done", action: dismiss.callAsFunction)
            .buttonStyle(PrimaryButtonStyle())
        
        makeTryAgainButton()
    }
    
    // MARK: - Info
    
    @ViewBuilder func makeCameraInstructions() -> some View {
        Text("Point your camera at the QR code on the auto parts packaging to earn points")
            .font(.callout)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.ultraThinMaterial)
            }
            .padding(.horizontal, 16)
    }
    
    @ViewBuilder func makeProcessingInstructions() -> some View {
        Text("Please do not close this screen until you receive your points")
            .font(.callout)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.ultraThinMaterial)
            }
            .padding(.horizontal, 16)
    }
}

#Preview {
    NavigationView {
        QRScannerView()
    }
}
