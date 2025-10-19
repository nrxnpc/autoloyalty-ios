# Caching Guide

Efficient data caching strategies and best practices with ScopeGraph.

## Overview

ScopeGraph's caching system provides high-performance, memory-efficient data storage with automatic expiration and size management.

## Cache Fundamentals

### Basic Cache Operations

```swift
// Create a cache for any Hashable key and any value type
let imageCache = Cache<URL, UIImage>()
let userCache = Cache<String, UserProfile>()

// Insert data
imageCache.insert(image, forKey: imageURL)
userCache.insert(user, forKey: user.id)

// Retrieve data
let cachedImage = imageCache.value(forKey: imageURL)
let cachedUser = userCache.value(forKey: user.id)
```

### Subscript Convenience

```swift
// Use subscript syntax for cleaner code
cache[key] = value
let value = cache[key]

// Remove entries by assigning nil
cache[key] = nil
```

## Cache Configuration

### Expiration Settings

```swift
// Configure cache with custom expiration
let cache = Cache<String, Data>(
    dateProvider: Date.init,
    entryLifetime: 1800, // 30 minutes
    maximumEntryCount: 50
)
```

### Size Limits

```swift
// Create cache with specific capacity
let limitedCache = Cache<String, LargeObject>(
    entryLifetime: 3600, // 1 hour
    maximumEntryCount: 10 // Only keep 10 items
)
```

## Advanced Caching Patterns

### Layered Caching

```swift
struct LayeredDataManager: ScopeGraphBuilder {
    private let memoryCache = Cache<String, Data>()
    private let diskCache = DiskCache()
    
    func getData(for key: String) async -> Data? {
        // Check memory cache first
        if let data = memoryCache.value(forKey: key) {
            return data
        }
        
        // Check disk cache
        if let data = await diskCache.data(for: key) {
            // Store in memory for faster access
            memoryCache.insert(data, forKey: key)
            return data
        }
        
        return nil
    }
}
```

### Cache Warming

```swift
struct PreloadingManager: ScopeGraphBuilder {
    private let cache = Cache<String, UserProfile>()
    
    func preloadCriticalData() async {
        let criticalUserIds = ["user1", "user2", "user3"]
        
        for userId in criticalUserIds {
            if let user = await fetchUser(id: userId) {
                cache.insert(user, forKey: userId)
            }
        }
    }
}
```

## Cache Persistence

### Saving to Disk

```swift
extension Cache where Key: Codable, Value: Codable {
    func persistToDisk(name: String) throws {
        try saveToDisk(withName: name)
    }
    
    func restoreFromDisk(name: String) throws -> Cache<Key, Value> {
        // Implementation for loading from disk
        return try Cache(from: decoder)
    }
}
```

### Background Persistence

```swift
struct PersistentCacheManager: ScopeGraphBuilder {
    private let cache = Cache<String, CacheableData>()
    
    func schedulePeriodicSave() {
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            Task {
                try? await self.saveCache()
            }
        }
    }
    
    private func saveCache() async throws {
        try cache.saveToDisk(withName: "app_cache")
    }
}
```

## Performance Optimization

### Memory Management

```swift
// Monitor cache performance
extension Cache {
    var memoryFootprint: Int {
        // Estimate memory usage
        return keyTracker.keys.count * MemoryLayout<Entry>.size
    }
    
    func optimizeMemory() {
        // Force cleanup of expired entries
        let currentDate = dateProvider()
        keyTracker.keys.forEach { key in
            _ = value(forKey: key) // Triggers expiration check
        }
    }
}
```

### Cache Metrics

```swift
struct CacheMetrics {
    var hitCount: Int = 0
    var missCount: Int = 0
    var evictionCount: Int = 0
    
    var hitRate: Double {
        let total = hitCount + missCount
        return total > 0 ? Double(hitCount) / Double(total) : 0
    }
}

class MonitoredCache<Key: Hashable, Value>: Cache<Key, Value> {
    private var metrics = CacheMetrics()
    
    override func value(forKey key: Key) -> Value? {
        let value = super.value(forKey: key)
        if value != nil {
            metrics.hitCount += 1
        } else {
            metrics.missCount += 1
        }
        return value
    }
}
```

## Best Practices

### Cache Key Design

```swift
// Use descriptive, hierarchical keys
struct CacheKeys {
    static func userProfile(id: String) -> String {
        return "user.profile.\(id)"
    }
    
    static func userAvatar(id: String, size: CGSize) -> String {
        return "user.avatar.\(id).\(Int(size.width))x\(Int(size.height))"
    }
    
    static func apiResponse(endpoint: String, params: [String: String]) -> String {
        let sortedParams = params.sorted { $0.key < $1.key }
        let paramString = sortedParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        return "api.\(endpoint).\(paramString.hash)"
    }
}
```

### Error Handling

```swift
struct SafeCacheManager: ScopeGraphBuilder {
    private let cache = Cache<String, Data>()
    
    func safelyStore<T: Codable>(_ object: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(object)
            cache.insert(data, forKey: key)
        } catch {
            print("Failed to cache object for key \(key): \(error)")
        }
    }
    
    func safelyRetrieve<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = cache.value(forKey: key) else { return nil }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            // Remove corrupted data
            cache.removeValue(forKey: key)
            print("Removed corrupted cache entry for key \(key): \(error)")
            return nil
        }
    }
}
```