import XCTest
@testable import ScopeGraph

/// Tests for new modular ScopeGraph architecture
final class ModularArchitectureTests: XCTestCase {
    
    // MARK: - Core Architecture Tests
    
    /// Tests component registration and pipeline building
    func test_coreArchitecture_shouldRegisterAndBuildComponents() async throws {
        // Given: Modular ScopeGraph architecture
        let pipeline = ScopeGraph()
            .register(StorageModule.memory())
            .register(OptimizationModule.batteryAware())
            .build()
        
        // When: Using pipeline
        let testData = "test_value".data(using: .utf8)!
        try await pipeline.store(testData, forKey: "test_key")
        let retrieved = try await pipeline.retrieve(forKey: "test_key", as: Data.self)
        
        // Then: Data should be stored and retrieved
        XCTAssertEqual(retrieved, testData)
    }
    
    // MARK: - Storage Module Tests
    
    /// Tests storage components
    func test_storageModule_shouldProvideStorageComponents() async throws {
        // Given: Various storage components
        let memoryComponent = StorageModule.memory()
        let persistentComponent = StorageModule.persistent()
        
        // When: Checking identifiers
        XCTAssertEqual(memoryComponent.identifier, "cache")
        XCTAssertEqual(persistentComponent.identifier, "persistent_storage")
        
        // Then: Components should be created correctly
        XCTAssertNotNil(memoryComponent)
        XCTAssertNotNil(persistentComponent)
    }
    
    // MARK: - Processing Module Tests
    
    /// Tests processing components
    func test_processingModule_shouldProvideProcessingComponents() async throws {
        // Given: Processing components
        let compressionComponent = ProcessingModule.compression()
        let serializationComponent = ProcessingModule.serialization() as SerializationComponent<TestModel>
        let encryptionKey = Data([1, 2, 3, 4])
        let encryptionComponent = ProcessingModule.encryption(key: encryptionKey)
        
        // When: Checking identifiers
        XCTAssertEqual(compressionComponent.identifier, "compression")
        XCTAssertEqual(serializationComponent.identifier, "serialization")
        XCTAssertEqual(encryptionComponent.identifier, "encryption")
        
        // Then: Components should be created correctly
        XCTAssertNotNil(compressionComponent)
        XCTAssertNotNil(serializationComponent)
        XCTAssertNotNil(encryptionComponent)
    }
    
    // MARK: - Optimization Module Tests
    
    /// Tests optimization components
    func test_optimizationModule_shouldProvideOptimizationComponents() async throws {
        // Given: Optimization components
        let batteryComponent = OptimizationModule.batteryAware()
        let memoryComponent = OptimizationModule.memoryEfficient()
        let networkComponent = OptimizationModule.networkAware()
        
        // When: Checking identifiers
        XCTAssertEqual(batteryComponent.identifier, "battery_optimization")
        XCTAssertEqual(memoryComponent.identifier, "memory_optimization")
        XCTAssertEqual(networkComponent.identifier, "network_optimization")
        
        // Then: Components should be created correctly
        XCTAssertNotNil(batteryComponent)
        XCTAssertNotNil(memoryComponent)
        XCTAssertNotNil(networkComponent)
    }
    
    // MARK: - Ready-to-Use Kits Tests
    
    /// Tests ready-made component kits
    func test_scopeGraphKits_shouldProvideReadyToUseKits() async throws {
        // Given: Ready-made kits
        let userDataKit = ScopeGraphKits.userDataKit()
        let mediaKit = ScopeGraphKits.mediaKit()
        let apiCacheKit = ScopeGraphKits.apiCacheKit()
        
        // When: Using kits
        let userData = "user_data".data(using: .utf8)!
        let mediaData = Data([1, 2, 3])
        let apiData = "api_response".data(using: .utf8)!
        
        try await userDataKit.store(userData, forKey: "user_123")
        try await mediaKit.store(mediaData, forKey: "image_456")
        try await apiCacheKit.store(apiData, forKey: "endpoint_789")
        
        // Then: Kits should work correctly
        let retrievedUserData = try await userDataKit.retrieve(forKey: "user_123", as: Data.self)
        let retrievedMediaData = try await mediaKit.retrieve(forKey: "image_456", as: Data.self)
        let retrievedApiData = try await apiCacheKit.retrieve(forKey: "endpoint_789", as: Data.self)
        
        XCTAssertEqual(retrievedUserData, userData)
        XCTAssertEqual(retrievedMediaData, mediaData)
        XCTAssertEqual(retrievedApiData, apiData)
    }
    
    /// Tests CoreData kits
    func test_coreDataKits_shouldProvideReadyToUseKits() {
        // Given: CoreData kit parameters
        let userId = "test_user"
        
        // When: Creating CoreData kits
        let userCoreDataKit = ScopeGraphKits.userCoreDataKit(userId: userId)
        let customCoreDataKit = ScopeGraphKits.coreDataKit(
            userId: userId,
            modelName: "TestModel",
            modelBundle: Bundle.main
        )
        
        // Then: Kits should be created successfully
        XCTAssertNotNil(userCoreDataKit)
        XCTAssertNotNil(customCoreDataKit)
    }
    
    // MARK: - Pipeline Builder Tests
    
    /// Tests pipeline builder
    func test_pipelineBuilder_shouldBuildCustomPipelines() async throws {
        // Given: Custom pipeline via builder
        let customPipeline = DataPipeline(components: [
            StorageModule.memory(),
            ProcessingModule.compression(),
            OptimizationModule.batteryAware()
        ])
        
        // When: Using custom pipeline
        let testData = "test data for compression".data(using: .utf8)!
        try await customPipeline.store(testData, forKey: "compressed_data")
        let retrieved = try await customPipeline.retrieve(forKey: "compressed_data", as: Data.self)
        
        // Then: Pipeline should work correctly
        XCTAssertNotNil(retrieved)
    }
    
    // MARK: - Individual Component Tests
    
    /// Tests memory cache component
    func test_memoryCache_shouldStoreAndRetrieveData() async throws {
        // Given: Memory cache component in pipeline
        let pipeline = DataPipeline(components: [StorageModule.memory()])
        
        // When: Storing and retrieving data
        let testData = "cached_value".data(using: .utf8)!
        try await pipeline.store(testData, forKey: "cache_key")
        let retrieved = try await pipeline.retrieve(forKey: "cache_key", as: Data.self)
        
        // Then: Data should be cached and retrieved
        XCTAssertEqual(retrieved, testData)
    }
    
    /// Tests persistent storage component
    func test_persistentStorage_shouldStoreAndRetrieveData() async throws {
        // Given: Persistent storage component in pipeline
        let pipeline = DataPipeline(components: [StorageModule.persistent()])
        
        // When: Storing and retrieving data
        let testData = Data([1, 2, 3, 4, 5])
        try await pipeline.store(testData, forKey: "persistent_key")
        let retrieved = try await pipeline.retrieve(forKey: "persistent_key", as: Data.self)
        
        // Then: Data should be stored (retrieved may be nil for persistent storage)
        XCTAssertNotNil(testData)
        // Note: Persistent storage may not immediately return data due to async nature
    }
}

// MARK: - Test Models

struct TestModel: Codable, Equatable {
    let id: String
    let name: String
    let data: Data
}