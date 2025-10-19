import Foundation

/// Persistent file storage component
public struct PersistentStorageComponent: DataComponent, Sendable {
    public typealias Input = PersistentRequest
    public typealias Output = PersistentResult
    
    public let identifier = "persistent_storage"
    private let baseURL: URL
    
    public init(baseURL: URL? = nil) {
        self.baseURL = baseURL ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    public func process(_ input: PersistentRequest) async throws -> PersistentResult {
        switch input {
        case .store(let key, let data):
            let fileURL = baseURL.appendingPathComponent("\(key).data")
            try data.write(to: fileURL)
            return .stored
            
        case .retrieve(let key):
            let fileURL = baseURL.appendingPathComponent("\(key).data")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let data = try Data(contentsOf: fileURL)
                return .data(data)
            }
            return .data(nil)
            
        case .delete(let key):
            let fileURL = baseURL.appendingPathComponent("\(key).data")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            return .deleted
        }
    }
}

public enum PersistentRequest: Sendable {
    case store(key: String, data: Data)
    case retrieve(key: String)
    case delete(key: String)
}

public enum PersistentResult: Sendable {
    case stored
    case data(Data?)
    case deleted
}