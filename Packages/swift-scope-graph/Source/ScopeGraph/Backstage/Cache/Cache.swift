import Foundation

/// Thread-safe cache implementation with automatic expiration
/// 
/// Provides high-performance caching with configurable expiration and memory limits.
/// Uses NSCache internally for automatic memory pressure handling.
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
final class Cache<Key: Hashable & Sendable, Value: Sendable>: @unchecked Sendable {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: @Sendable () -> Date
    private let entryLifetime: TimeInterval
    private let keyTracker = KeyTracker()
    
    /// Initialize cache with configuration
    /// - Parameters:
    ///   - dateProvider: Date provider for expiration (default: Date.init)
    ///   - entryLifetime: How long entries remain valid (default: 12 hours)
    ///   - maximumEntryCount: Maximum number of entries (default: 50)
    init(dateProvider: @escaping @Sendable () -> Date = Date.init,
         entryLifetime: TimeInterval = 12 * 60 * 60,
         maximumEntryCount: Int = 50) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
    }
    
    /// Insert a value into the cache with automatic expiration
    /// - Parameters:
    ///   - value: Value to cache
    ///   - key: Cache key
    func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.add(key)
    }

    /// Retrieve a value from the cache
    /// - Parameter key: Cache key
    /// - Returns: Cached value or nil if not found or expired
    func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }

        return entry.value
    }
    
    /// Remove a value from the cache
    /// - Parameter key: Cache key to remove
    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
}

private extension Cache {
    func entry(forKey key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }
        
        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }
        
        return entry
    }
    
    func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.add(entry.key)
    }
}

private extension Cache {
    final class KeyTracker: NSObject, NSCacheDelegate, @unchecked Sendable {
        let keys = NSMutableSet()
        
        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject object: Any) {
            guard let entry = object as? Entry else {
                return
            }
            
            keys.remove(entry.key)
        }
    }
}

private extension Cache {
    final class WrappedKey: NSObject, @unchecked Sendable {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            
            return value.key == key
        }
    }
}

private extension Cache {
    final class Entry: @unchecked Sendable {
        let key: Key
        let value: Value
        let expirationDate: Date
        
        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}

extension Cache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}

extension Cache.Entry: Codable where Key: Codable, Value: Codable {}

extension Cache: Codable where Key: Codable, Value: Codable {
    convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let keyArray = Array(keyTracker.keys).compactMap { key -> Entry? in
            guard let typedKey = key as? Key else { return nil }
            return entry(forKey: typedKey)
        }
        try container.encode(keyArray)
    }
}

extension Cache where Key: Codable, Value: Codable {
    func saveToDisk(
        withName name: String,
        using fileManager: FileManager = .default
    ) throws {
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )

        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        let data = try JSONEncoder().encode(self)
        try data.write(to: fileURL)
    }
}
