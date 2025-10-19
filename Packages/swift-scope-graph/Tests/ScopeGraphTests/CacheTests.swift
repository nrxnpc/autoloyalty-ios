import XCTest
@testable import ScopeGraph

/// Tests demonstrating cache functionality and performance optimization.
/// Shows how to use the Cache system for efficient data storage and retrieval.
final class CacheTests: XCTestCase {
    
    private var cache: Cache<String, String>!
    
    override func setUp() {
        super.setUp()
        cache = Cache<String, String>()
    }
    
    // MARK: - Basic Cache Operations
    
    /// Demonstrates basic cache insertion and retrieval.
    /// Shows the fundamental cache operations for storing and accessing data.
    func test_basicCacheOperations_shouldStoreAndRetrieveValues() {
        // Given: A cache and some test data
        let key = "user_123"
        let value = "John Doe"
        
        // When: Inserting and retrieving data
        cache.insert(value, forKey: key)
        let retrievedValue = cache.value(forKey: key)
        
        // Then: The value should be correctly stored and retrieved
        XCTAssertEqual(retrievedValue, value, "Cache should return the stored value")
    }
    
    /// Shows cache behavior with subscript syntax.
    /// Demonstrates the convenient subscript interface for cache access.
    func test_subscriptAccess_shouldProvideConvenientInterface() {
        // Given: A cache with subscript access
        let key = "config_theme"
        let value = "dark_mode"
        
        // When: Using subscript syntax
        cache[key] = value
        let retrievedValue = cache[key]
        
        // Then: Subscript should work like direct methods
        XCTAssertEqual(retrievedValue, value, "Subscript access should work correctly")
    }
    
    // MARK: - Cache Expiration
    
    /// Demonstrates cache entry expiration functionality.
    /// Shows how cached data automatically expires after the configured lifetime.
    func test_cacheExpiration_shouldRemoveExpiredEntries() async {
        // Given: A cache with short expiration time
        let shortLivedCache = Cache<String, String>(
            dateProvider: Date.init,
            entryLifetime: 0.1, // 100ms
            maximumEntryCount: 10
        )
        
        let key = "temp_data"
        let value = "temporary_value"
        
        // When: Inserting data and waiting for expiration
        shortLivedCache.insert(value, forKey: key)
        
        // Immediately after insertion, value should be available
        XCTAssertEqual(shortLivedCache.value(forKey: key), value)
        
        // After expiration time, value should be nil
        let expectation = expectation(description: "Cache expiration")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertNil(shortLivedCache.value(forKey: key), "Expired entries should be removed")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - Cache Limits
    
    /// Shows cache behavior when maximum entry count is reached.
    /// Demonstrates automatic eviction of least recently used entries.
    func test_cacheLimits_shouldEvictOldestEntries() {
        // Given: A cache with limited capacity
        let limitedCache = Cache<String, String>(
            entryLifetime: 3600, // 1 hour
            maximumEntryCount: 2
        )
        
        // When: Adding more entries than the limit
        limitedCache.insert("value1", forKey: "key1")
        limitedCache.insert("value2", forKey: "key2")
        limitedCache.insert("value3", forKey: "key3") // Should evict key1
        
        // Then: Oldest entry should be evicted
        XCTAssertNil(limitedCache.value(forKey: "key1"), "Oldest entry should be evicted")
        XCTAssertNotNil(limitedCache.value(forKey: "key2"), "Recent entries should remain")
        XCTAssertNotNil(limitedCache.value(forKey: "key3"), "Newest entry should be available")
    }
    
    // MARK: - Cache Removal
    
    /// Demonstrates explicit cache entry removal.
    /// Shows how to manually remove entries from the cache.
    func test_cacheRemoval_shouldRemoveSpecificEntries() {
        // Given: A cache with stored data
        let key = "removable_data"
        let value = "data_to_remove"
        
        cache.insert(value, forKey: key)
        XCTAssertNotNil(cache.value(forKey: key), "Value should be initially present")
        
        // When: Removing the entry
        cache.removeValue(forKey: key)
        
        // Then: The entry should no longer be available
        XCTAssertNil(cache.value(forKey: key), "Removed entry should not be available")
    }
    
    /// Shows cache removal using subscript with nil assignment.
    /// Demonstrates the convenient nil assignment for removal.
    func test_subscriptRemoval_shouldRemoveEntriesWithNilAssignment() {
        // Given: A cache with stored data
        let key = "subscript_removable"
        let value = "data_to_remove"
        
        cache[key] = value
        XCTAssertNotNil(cache[key], "Value should be initially present")
        
        // When: Assigning nil via subscript
        cache[key] = nil
        
        // Then: The entry should be removed
        XCTAssertNil(cache[key], "Nil assignment should remove the entry")
    }
}

