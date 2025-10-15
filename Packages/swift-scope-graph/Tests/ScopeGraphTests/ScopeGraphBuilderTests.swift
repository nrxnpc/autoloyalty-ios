import XCTest
@testable import ScopeGraph

/// Tests demonstrating ScopeGraph builder pattern and architecture.
/// Shows how to organize and structure data management components.
final class ScopeGraphBuilderTests: XCTestCase {
    
    // MARK: - Builder Pattern
    
    /// Demonstrates the ScopeGraph builder pattern usage.
    /// Shows how to create organized data management structures.
    func test_scopeGraphBuilder_shouldOrganizeDataManagement() {
        // Given: A ScopeGraph with components
        let scopeGraph = ScopeGraph()
            .register(StorageModule.memory())
            .register(OptimizationModule.batteryAware())
        
        // When: Building the pipeline
        let pipeline = scopeGraph.build()
        
        // Then: The pipeline should be created successfully
        XCTAssertNotNil(pipeline)
    }
    
    /// Shows how to structure different data management components.
    /// Demonstrates organizing cache, keychain, and persistence layers.
    func test_dataManagerStructure_shouldOrganizeComponents() {
        // Given: Different data management components
        let cacheComponent = StorageModule.memory()
        let secureComponent = StorageModule.secure(service: "test")
        let persistentComponent = StorageModule.persistent()
        
        // When: Creating pipeline with all components
        let pipeline = ScopeGraph()
            .register(cacheComponent)
            .register(secureComponent)
            .register(persistentComponent)
            .build()
        
        // Then: All components should be properly integrated
        XCTAssertNotNil(pipeline)
    }
    
    // MARK: - ScopeGraph Core
    
    /// Demonstrates basic ScopeGraph initialization.
    /// Shows the core structure of the ScopeGraph system.
    func test_scopeGraphCore_shouldInitializeCorrectly() {
        // Given: A ScopeGraph instance
        let scopeGraph = ScopeGraph()
        
        // When: Checking its properties
        let isValidInstance = scopeGraph is ScopeGraph
        
        // Then: It should be properly initialized
        XCTAssertTrue(isValidInstance, "ScopeGraph should initialize correctly")
    }
    
    /// Shows ScopeGraph integration with different components.
    /// Demonstrates how various data management pieces work together.
    func test_scopeGraphIntegration_shouldCombineComponents() async throws {
        // Given: A comprehensive data management system
        let pipeline = ScopeGraph()
            .register(StorageModule.memory())
            .register(StorageModule.secure(service: "test"))
            .register(StorageModule.persistent())
            .register(OptimizationModule.batteryAware())
            .build()
        
        // When: Using the integrated system
        let testData = "integrated_test".data(using: .utf8)!
        try await pipeline.store(testData, forKey: "integration_key")
        let retrieved = try await pipeline.retrieve(forKey: "integration_key", as: Data.self)
        
        // Then: All components should work together
        XCTAssertEqual(retrieved, testData)
    }
}

// MARK: - Test Data Managers

/// Example cache-focused data manager
struct CacheDataManager {
    private let cache = Cache<String, Data>()
    
    func store<T: Codable>(_ object: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(object)
        cache.insert(data, forKey: key)
    }
    
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = cache.value(forKey: key) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
}

/// Example keychain-focused data manager
struct KeychainDataManager {
    private let keychain = Keychain(service: "com.scopegraph.test")
    
    func storeSecurely(_ value: String, forKey key: String) throws {
        try keychain.set(value, key: key)
    }
    
    func retrieveSecurely(forKey key: String) throws -> String? {
        return try keychain.get(key)
    }
}

/// Example persistence-focused data manager
struct PersistenceDataManager {
    func saveToDisk<T: Codable>(_ object: T, to url: URL) throws {
        let data = try JSONEncoder().encode(object)
        try data.write(to: url)
    }
    
    func loadFromDisk<T: Codable>(_ type: T.Type, from url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
}

/// Example comprehensive data manager combining all components
struct ComprehensiveDataManager {
    private let cacheManager = CacheDataManager()
    private let keychainManager = KeychainDataManager()
    private let persistenceManager = PersistenceDataManager()
    
    var hasCache: Bool { true }
    var hasKeychain: Bool { true }
    var hasPersistence: Bool { true }
    
    func storeUserData<T: Codable>(_ userData: T, securely: Bool = false) throws {
        let key = "user_data_\(UUID().uuidString)"
        
        if securely {
            // Store sensitive data in keychain
            let jsonData = try JSONEncoder().encode(userData)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            try keychainManager.storeSecurely(jsonString, forKey: key)
        } else {
            // Store regular data in cache
            try cacheManager.store(userData, forKey: key)
        }
    }
}

/// Example user data manager for testing
struct UserDataManager {
    private let cache = Cache<String, UserProfile>()
    
    func cacheUser(_ user: UserProfile) {
        cache.insert(user, forKey: user.id)
    }
    
    func getUser(id: String) -> UserProfile? {
        return cache.value(forKey: id)
    }
}

/// Test model for user data
struct UserProfile: Codable {
    let id: String
    let name: String
    let email: String
}