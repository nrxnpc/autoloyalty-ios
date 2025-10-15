import Foundation

/// High-performance in-memory cache storage component
/// 
/// Provides fast, thread-safe caching with automatic expiration and memory management.
/// Ideal for frequently accessed data that doesn't require persistence.
/// 
/// Features:
/// - Automatic expiration based on configurable lifetime
/// - Memory pressure handling with LRU eviction
/// - Type-safe key-value storage
/// - Thread-safe operations
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public struct CacheComponent<Key: Hashable & Sendable, Value: Sendable>: DataComponent, StorageComponentProtocol, Sendable {
    public typealias Input = StorageOperation<Value>
    public typealias Output = StorageResult<Value>
    
    private let cache: Cache<Key, Value>
    public let identifier = "cache"
    
    /// Initialize cache component with default settings
    public init() {
        self.cache = Cache<Key, Value>()
    }
    
    /// Initialize cache component with custom configuration
    /// - Parameters:
    ///   - entryLifetime: How long entries remain valid (default: 12 hours)
    ///   - maximumEntryCount: Maximum number of entries (default: 50)
    public init(entryLifetime: TimeInterval = 12 * 60 * 60, maximumEntryCount: Int = 50) {
        self.cache = Cache<Key, Value>(entryLifetime: entryLifetime, maximumEntryCount: maximumEntryCount)
    }
    
    /// Process storage operations
    /// - Parameter input: Storage operation to perform
    /// - Returns: Operation result
    /// - Throws: Processing errors
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
    
    /// Store a value in the cache
    /// - Parameters:
    ///   - value: Value to store
    ///   - key: Cache key
    /// - Throws: Storage errors
    public func store<T: Sendable>(_ value: T, forKey key: String) async throws {
        if let typedValue = value as? Value, let typedKey = key as? Key {
            cache.insert(typedValue, forKey: typedKey)
        }
    }
    
    /// Retrieve a value from the cache
    /// - Parameters:
    ///   - key: Cache key
    ///   - type: Expected value type
    /// - Returns: Cached value or nil if not found/expired
    /// - Throws: Storage errors
    public func retrieve<T: Sendable>(forKey key: String, as type: T.Type) async throws -> T? {
        if let typedKey = key as? Key {
            return cache.value(forKey: typedKey) as? T
        }
        return nil
    }
    
    /// Remove a value from the cache
    /// - Parameter key: Cache key to remove
    /// - Throws: Storage errors
    public func remove(forKey key: String) async throws {
        if let typedKey = key as? Key {
            cache.removeValue(forKey: typedKey)
        }
    }
}