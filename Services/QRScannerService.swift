import AVFoundation
import UIKit
import SwiftUI

class QRScannerService: NSObject, ObservableObject {
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "camera.session", qos: .userInitiated)
    
    @Published var isScanning = false
    private var scanCompletion: ((String) -> Void)?
    
    func startScanning(completion: @escaping (String) -> Void) {
        self.scanCompletion = completion
        
        sessionQueue.async { [weak self] in
            self?.setupOptimizedSession()
        }
    }
    
    private func setupOptimizedSession() {
        let session = AVCaptureSession()
        
        // Понижаем качество для экономии ресурсов
        session.sessionPreset = .medium
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr]
            
            // Ограничиваем область сканирования для производительности
            output.rectOfInterest = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
        }
        
        captureSession = session
        
        DispatchQueue.main.async {
            self.isScanning = true
        }
        
        session.startRunning()
    }
    
    func stopScanning() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
            self?.captureSession = nil
            
            DispatchQueue.main.async {
                self?.isScanning = false
            }
        }
    }
}

extension QRScannerService: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }
        
        // Немедленно останавливаем сканирование
        stopScanning()
        
        // Вибрация на главном потоке
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        scanCompletion?(stringValue)
        scanCompletion = nil
    }
}

// MARK: - QR Code Scanner View

struct QRCodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QRScannerDelegate {
        let parent: QRCodeScannerView
        
        init(_ parent: QRCodeScannerView) {
            self.parent = parent
        }
        
        func didScanQRCode(_ code: String) {
            parent.scannedCode = code
            parent.dismiss()
        }
    }
}

protocol QRScannerDelegate: AnyObject {
    func didScanQRCode(_ code: String)
}

class QRScannerViewController: UIViewController {
    weak var delegate: QRScannerDelegate?
    private var captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    private func setupCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        // Оптимизация: понижаем качество
        captureSession.sessionPreset = .medium
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
            
            // Оптимизация: устанавливаем область интереса
            metadataOutput.rectOfInterest = CGRect(x: 0.3, y: 0.3, width: 0.4, height: 0.4)
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
    private func setupUI() {
        // Добавляем рамку для сканирования
        let scanFrame = UIView()
        scanFrame.layer.borderColor = UIColor.red.cgColor
        scanFrame.layer.borderWidth = 2
        scanFrame.layer.cornerRadius = 10
        scanFrame.backgroundColor = UIColor.clear
        
        let frameSize: CGFloat = 250
        scanFrame.frame = CGRect(
            x: (view.bounds.width - frameSize) / 2,
            y: (view.bounds.height - frameSize) / 2,
            width: frameSize,
            height: frameSize
        )
        
        view.addSubview(scanFrame)
        
        // Добавляем инструкцию
        let instructionLabel = UILabel()
        instructionLabel.text = "Наведите камеру на QR-код"
        instructionLabel.textColor = .white
        instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        instructionLabel.textAlignment = .center
        instructionLabel.layer.cornerRadius = 10
        instructionLabel.clipsToBounds = true
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        instructionLabel.frame = CGRect(
            x: 20,
            y: view.safeAreaInsets.top + 20,
            width: view.bounds.width - 40,
            height: 50
        )
        
        view.addSubview(instructionLabel)
        
        // Кнопка закрытия
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Закрыть", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor.red
        closeButton.layer.cornerRadius = 25
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        closeButton.frame = CGRect(
            x: (view.bounds.width - 100) / 2,
            y: view.bounds.height - view.safeAreaInsets.bottom - 80,
            width: 100,
            height: 50
        )
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // Добавляем вибрацию при успешном сканировании
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            delegate?.didScanQRCode(stringValue)
        }
    }
}
