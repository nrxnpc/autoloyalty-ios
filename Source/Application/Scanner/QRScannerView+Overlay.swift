import SwiftUI

// MARK: - View Builders

extension QRScannerView {
    // MARK: - Overlay
    
    @ViewBuilder func makeCameraOverlay() -> some View {
        ZStack {
            MakeIcon(systemImage: "camera.badge.clock", size: .large)
                .foregroundStyle(.ultraThinMaterial)
                .opacity(captureSession.isSessionConfigured ? 0 : 1)
                .id("camera.badge.clock")
            
            switch scanner.scanningState {
            case .scanning: makeViewfinder()
            case .processing: makeProcessing()
            case .result(let earnedPoints): makeResult(with: earnedPoints)
            case .processingError: makeProcessingError()
            }
        }
        .animation(.smooth, value: scanner.scanningState)
        .id("capture")
    }
    
    @ViewBuilder private func makeViewfinder() -> some View {
        Viewfinder()
            .aspectRatio(1, contentMode: .fit)
            .padding(.horizontal, 32)
        
        VStack {
            Spacer()
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 32)
            
            Text("Point your camera at the QR code on the auto parts packaging to earn points")
                .font(.callout)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.ultraThinMaterial)
                }
                .padding(.top, 96)
                .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder private func makeProcessing() -> some View {
        RoundedRectangle(cornerRadius: 32)
            .aspectRatio(1, contentMode: .fit)
            .padding(.horizontal, 32)
            .foregroundStyle(.ultraThinMaterial)
            .overlay {
                VStack(spacing: 16) {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.icloud")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary, .tertiary)
                        .symbolEffect(.rotate)
                        .padding(.horizontal, 64)
                    
                    Text("Processing, please do not close this screen until you receive your points")
                        .font(.callout)
                        .padding(.horizontal, 32)
                }
                .padding()
            }
    }
    
    @ViewBuilder private func makeResult(with earnedPoints: Int) -> some View {
        RoundedRectangle(cornerRadius: 32)
            .aspectRatio(1, contentMode: .fit)
            .padding(.horizontal, 32)
            .foregroundStyle(.ultraThinMaterial)
            .overlay {
                VStack(alignment: .center, spacing: 16) {
                    BalanceLabel(points: earnedPoints)
                        .font(.largeTitle)
                    
                    Text("Points successfully added to your balance!")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding()
            }
            .confettiCannon(trigger: .constant(true))
    }
    
    @ViewBuilder private func makeProcessingError() -> some View {
        RoundedRectangle(cornerRadius: 32)
            .aspectRatio(1, contentMode: .fit)
            .padding(.horizontal, 32)
            .foregroundStyle(.ultraThinMaterial)
            .overlay {
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
                .padding()
            }
    }
}

#Preview {
    QRScannerView()
}
