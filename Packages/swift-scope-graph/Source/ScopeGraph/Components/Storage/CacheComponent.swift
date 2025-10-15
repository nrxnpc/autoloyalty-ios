import Foundation

/// In-memory cache storage component
public struct CacheComponent<Key: Hashable & Sendable, Value: Sendable>: DataComponent, StorageComponentProtocol, Sendable {
    public typealias Input = StorageOperation<Value>
    public typealias Output = StorageResult<Value>
    
    private let cache: Cache<Key, Value>
    public let identifier = "cache"
    
    public init() {
        self.cache = Cache<Key, Value>()
    }
    
    public func process(_ input: StorageOperation<Value>) async throws -> StorageResult<Value> {
        switch input {
        case .store(let key, let value):
            if let typedKey = key as? Key {
                cache.insert(value, forKey: typedKey)
            }
            return .success
        case .retrieve(let key):
            if let typedKey = key as? Key {
                return .value(cache.value(forKey: typedKey))
            }
            return .value(nil)
        case .remove(let key):
            if let typedKey = key as? Key {
                cache.removeValue(forKey: typedKey)
            }
            return .removed
        }
    }
    
    public func store<T>(_ value: T, forKey key: String) async throws {
        if let typedValue = value as? Value, let typedKey = key as? Key {
            cache.insert(typedValue, forKey: typedKey)
        }
    }
    
    public func retrieve<T>(forKey key: String, as type: T.Type) async throws -> T? {
        if let typedKey = key as? Key {
            return cache.value(forKey: typedKey) as? T
        }
        return nil
    }
    
    public func remove(forKey key: String) async throws {
        if let typedKey = key as? Key {
            cache.removeValue(forKey: typedKey)
        }
    }
}