import SwiftUI
import SwiftUIComponents

struct QRScannerView: View, ComponentBuilder {
    // MARK: - Dependencies
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: Main.Router
    
    // MARK: - State
    
    @StateObject var scanner = QRScanner()
    @StateObject var captureSession = CaptureSession()
    
    var body: some View {
        ZStack {
            switch scanner.captureDeviceState {
            case .unowned: EmptyView()
            case .requestCameraAccess: makeRequestCameraAccess()
            case .cameraAccessRequired: makeCameraAccessRequired()
            case .cameraPreview: makeCameraPreview()
            }
        }
        .ignoresSafeArea()
        .toolbar(content: makeToolbar)
        .animation(.easeInOut, value: scanner.captureDeviceState)
        .onChange(of: captureSession.detectedQRCode) {
            if let value = captureSession.detectedQRCode {
                scanner.process(code: value)
            }
        }
    }
}

// MARK: - View Builders

extension QRScannerView {
    @ViewBuilder func makeDismissButton() -> some View {
        Button {
            dismiss()
        } label: {
            MakeIcon(systemImage: "x.circle.fill", size: .small)
                .foregroundStyle(.ultraThinMaterial)
        }
        .padding()
    }
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }
    }
}

struct Viewfinder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 32)
            .stroke(style: .init(lineWidth: 4, dash: [16, 16]))
            .foregroundStyle(.ultraThinMaterial)
    }
}

#Preview {
    QRScannerView()
}
