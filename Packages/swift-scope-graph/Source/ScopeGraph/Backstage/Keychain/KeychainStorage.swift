import Foundation

/// Draft: do not use
/// Property wrapper for secure keychain storage
@propertyWrapper
public struct KeychainStorage<T: Codable>: Sendable {
    private let keychain: Keychain
    private let key: String
    
    public init(key: String, service: String = Bundle.main.bundleIdentifier ?? "default") {
        self.key = key
        self.keychain = Keychain(service: service)
    }
    
    public var wrappedValue: T? {
        get {
            guard let data = try? keychain.getData(key) else { return nil }
            return try? JSONDecoder().decode(T.self, from: data)
        }
        set {
            if let value = newValue {
                let data = try? JSONEncoder().encode(value)
                try? keychain.set(data!, key: key)
            } else {
                try? keychain.remove(key)
            }
        }
    }
}

/// Specialized property wrapper for session tokens
@propertyWrapper
public struct KeychainTokens<T: Codable>: Sendable {
    private var storage: KeychainStorage<T>
    
    public init(key: String, service: String = "com.note-mess.tokens") {
        self.storage = KeychainStorage(key: key, service: service)
    }
    
    public var wrappedValue: T? {
        get { storage.wrappedValue }
        set { storage.wrappedValue = newValue }
    }
}
