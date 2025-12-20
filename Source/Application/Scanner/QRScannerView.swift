import SwiftUI
import SwiftUIComponents

struct QRScannerView: View, ComponentBuilder {
    // MARK: - Dependencies
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: Main.Router
    @EnvironmentObject var captureSession: CaptureSession
    
    // MARK: - State
    
    @StateObject var scanner = QRScanner()
    @State var confettiCannonTrigger = 0
    
    var body: some View {
        ZStack {
            makePage {
                switch scanner.captureDeviceState {
                case .unowned: EmptyView()
                case .requestCameraAccess: makeRequestCameraAccess()
                case .cameraAccessRequired: makeCameraAccessRequired()
                case .cameraPreview: makeCameraPreview()
                case .processing: makeProcessing()
                case .result(let points): makeResult(with: points)
                case .processingError: makeProcessingError()
                }
            } action: {
                switch scanner.captureDeviceState {
                case .unowned: EmptyView()
                case .requestCameraAccess: makeAllowCameraButton()
                case .cameraAccessRequired: makeSettingsButton()
                case .cameraPreview: makeCameraInstructions()
                case .processing: makeProcessingInstructions()
                case .result: makeFinishButton()
                case .processingError: makeTryAgainButton()
                }
            }
        }
        .confettiCannon(trigger: $confettiCannonTrigger, num: 100, openingAngle: .degrees(0), closingAngle: .degrees(180), radius: 400, repetitions: 2, repetitionInterval: 0.25)
        .task {
            captureSession.prepareForUse()
        }
        .onDisappear {
            captureSession.stopRunning()
        }
        .toolbar(content: makeToolbar)
        .onChange(of: captureSession.detectedQRCode) {
            guard let value = captureSession.detectedQRCode else { return }
            Task { @MainActor in
                await scanner.process(code: value)
            }
        }
    }
}

// MARK: - View Builders

extension QRScannerView {
    @ViewBuilder func makePage<Content: View, Action: View>(@ViewBuilder content: () -> Content, @ViewBuilder action: () -> Action) -> some View {
        ZStack {
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    content()
                        .transition(.opacity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .containerRelativeFrame(.vertical) { height, _ in
                    height * 0.75
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundStyle(.ultraThinMaterial)
                }
                
                Spacer()
                    .frame(height: 16)
                
                VStack(alignment: .center, spacing: 16) {
                    action()
                        .transition(.opacity.combined(with: .scale))
                }
                .padding()
            }
        }
        .padding(.horizontal)
        .animation(.smooth, value: scanner.captureDeviceState)
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
            .stroke(style: .init(lineWidth: 2, dash: [16, 16]))
            .foregroundStyle(.white)
    }
}

#Preview {
    NavigationView {
        QRScannerView()
    }
}
