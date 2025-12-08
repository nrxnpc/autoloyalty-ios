import AVFoundation

final class CapturePermission {
    
    // MARK: - Typedef
    
    enum Status {
        case undefined, granted, restricted
    }
    
    typealias Completion = (Status) -> ()
    
    // MARK: -
    
    var status: Status {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: return .undefined
        case .authorized: return .granted
        case .denied, .restricted: return .restricted
        @unknown default: fatalError("An error occurred while checking authorization status.")
        }
    }
}

extension CapturePermission {
    func requestPermission(completion: @escaping Completion) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted  {
                completion(.granted)
            } else {
                completion(.restricted)
            }
        }
    }
}
