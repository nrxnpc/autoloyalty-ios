import Foundation

/// Secure keychain storage component
public struct SecureStorageComponent: DataComponent, StorageComponentProtocol, Sendable {
    public typealias Input = SecureOperation
    public typealias Output = SecureResult
    
    private let keychain: Keychain
    public let identifier = "secure_storage"
    
    public init(service: String) {
        self.keychain = Keychain(service: service)
    }
    
    public func process(_ input: SecureOperation) async throws -> SecureResult {
        switch input {
        case .store(let key, let value):
            try keychain.set(value, key: key)
            return .success
        case .retrieve(let key):
            return .data(try keychain.getData(key))
        case .remove(let key):
            try keychain.remove(key)
            return .removed
        }
    }
    
    public func store<T>(_ value: T, forKey key: String) async throws {
        if let data = value as? Data {
            try keychain.set(data, key: key)
        } else if let codable = value as? any Codable {
            let data = try JSONEncoder().encode(codable)
            try keychain.set(data, key: key)
        }
    }
    
    public func retrieve<T>(forKey key: String, as type: T.Type) async throws -> T? {
        guard let data = try keychain.getData(key) else { return nil }
        
        if type == Data.self {
            return data as? T
        } else if let codableType = type as? any Codable.Type {
            return try JSONDecoder().decode(codableType, from: data) as? T
        }
        return nil
    }
    
    public func remove(forKey key: String) async throws {
        try keychain.remove(key)
    }
}