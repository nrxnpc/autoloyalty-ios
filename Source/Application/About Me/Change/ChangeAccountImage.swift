import SwiftUI
import PhotosUI
import CoreTransferable

@MainActor
final class ChangeAccountImage: ObservableObject {
    // MARK: - Published
    
    @Published private(set) var imageState: ImageState = .empty
    @Published var photosPickerItem: PhotosPickerItem? = nil {
        didSet {
            if let photosPickerItem {
                let progress = loadTransferable(from: photosPickerItem)
                imageState = .loading(progress)
            } else {
                imageState = .empty
            }
        }
    }
}

extension ChangeAccountImage {
    // MARK: - Typedef
    
    enum ImageState: Equatable {
        case empty
        case loading(Progress)
        case success(Data)
        case failure(Error)
        
        static func == (lhs: ChangeAccountImage.ImageState, rhs: ChangeAccountImage.ImageState) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty):
                return true
            case (.loading(let p1), .loading(let p2)):
                return p1 == p2
            case (.success(let i1), .success(let i2)):
                return i1 == i2
            case (.failure, .failure):
                return true
            default:
                return false
            }
        }
    }
    
    enum TransferError: Error {
        case importFailed
    }
    
    // MARK: -
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self, imageSelection == self.photosPickerItem else {
                    return
                }
                
                switch result {
                case .success(let data):
                    if let data {
                        self.imageState = .success(data)
                    } else {
                        self.imageState = .failure(TransferError.importFailed)
                    }
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }
}
