import XCTest
@testable import ScopeGraph

/// Tests demonstrating secure keychain storage functionality.
/// Shows how to securely store and retrieve sensitive data using the Keychain.
final class KeychainTests: XCTestCase {
    
    private var keychain: Keychain!
    private let testService = "com.scopegraph.tests"
    
    override func setUp() {
        super.setUp()
        keychain = Keychain(service: testService)
        
        // Clean up any existing test data
        try? keychain.removeAll()
    }
    
    override func tearDown() {
        // Clean up test data
        try? keychain.removeAll()
        super.tearDown()
    }
    
    // MARK: - Basic Keychain Operations
    
    /// Demonstrates basic keychain storage and retrieval.
    /// Shows how to securely store sensitive strings in the keychain.
    func test_basicKeychainOperations_shouldStoreAndRetrieveSecurely() throws {
        // Given: Sensitive data to store
        let key = "user_token"
        let sensitiveValue = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
        
        // When: Storing and retrieving from keychain
        try keychain.set(sensitiveValue, key: key)
        let retrievedValue = try keychain.get(key)
        
        // Then: The value should be securely stored and retrieved
        XCTAssertEqual(retrievedValue, sensitiveValue, "Keychain should securely store and retrieve values")
    }
    
    /// Shows keychain behavior with subscript syntax.
    /// Demonstrates the convenient subscript interface for keychain access.
    func test_subscriptAccess_shouldProvideConvenientInterface() {
        // Given: A keychain with subscript access
        let key = "api_key"
        let value = "sk_test_123456789"
        
        // When: Using subscript syntax
        keychain[key] = value
        let retrievedValue = keychain[key]
        
        // Then: Subscript should work like direct methods
        XCTAssertEqual(retrievedValue, value, "Subscript access should work correctly")
    }
    
    // MARK: - Data Storage
    
    /// Demonstrates storing binary data in the keychain.
    /// Shows how to store Data objects securely.
    func test_dataStorage_shouldStoreBinaryDataSecurely() throws {
        // Given: Binary data to store
        let key = "encryption_key"
        let binaryData = Data([0x01, 0x02, 0x03, 0x04, 0x05])
        
        // When: Storing and retrieving binary data
        try keychain.set(binaryData, key: key)
        let retrievedData = try keychain.getData(key)
        
        // Then: Binary data should be correctly stored and retrieved
        XCTAssertEqual(retrievedData, binaryData, "Keychain should handle binary data correctly")
    }
    
    // MARK: - Keychain Security
    
    /// Shows keychain accessibility configuration.
    /// Demonstrates different security levels for stored data.
    func test_keychainAccessibility_shouldConfigureSecurityLevels() throws {
        // Given: A keychain with specific accessibility settings
        let secureKeychain = keychain.accessibility(.whenUnlockedThisDeviceOnly)
        let key = "secure_data"
        let value = "highly_sensitive_information"
        
        // When: Storing with enhanced security
        try secureKeychain.set(value, key: key)
        let retrievedValue = try secureKeychain.get(key)
        
        // Then: Data should be stored with appropriate security level
        XCTAssertEqual(retrievedValue, value, "Secure keychain should store data correctly")
    }
    
    // MARK: - Keychain Queries
    
    /// Demonstrates checking for keychain item existence.
    /// Shows how to verify if data exists without retrieving it.
    func test_keychainContains_shouldCheckExistenceWithoutRetrieval() throws {
        // Given: A keychain with stored data
        let key = "existence_check"
        let value = "test_data"
        
        // Initially, key should not exist
        XCTAssertFalse(try keychain.contains(key), "Key should not exist initially")
        
        // When: Storing data
        try keychain.set(value, key: key)
        
        // Then: Key should exist
        XCTAssertTrue(try keychain.contains(key), "Key should exist after storage")
    }
    
    /// Shows keychain item removal.
    /// Demonstrates how to securely delete stored data.
    func test_keychainRemoval_shouldDeleteStoredData() throws {
        // Given: A keychain with stored data
        let key = "removable_data"
        let value = "data_to_remove"
        
        try keychain.set(value, key: key)
        XCTAssertTrue(try keychain.contains(key), "Data should be initially present")
        
        // When: Removing the data
        try keychain.remove(key)
        
        // Then: The data should no longer exist
        XCTAssertFalse(try keychain.contains(key), "Data should be removed")
        XCTAssertNil(try keychain.get(key), "Removed data should return nil")
    }
    
    // MARK: - Error Handling
    
    /// Demonstrates keychain error handling.
    /// Shows how to handle various keychain operation failures.
    func test_keychainErrors_shouldHandleFailuresGracefully() {
        // Given: An invalid keychain operation
        let nonExistentKey = "non_existent_key"
        
        // When: Attempting to retrieve non-existent data
        do {
            let value = try keychain.get(nonExistentKey)
            // Then: Should return nil for non-existent keys
            XCTAssertNil(value, "Non-existent keys should return nil")
        } catch {
            XCTFail("Getting non-existent key should not throw error: \(error)")
        }
    }
    
    // MARK: - Keychain Attributes
    
    /// Shows keychain item attributes and metadata.
    /// Demonstrates how to retrieve additional information about stored items.
    func test_keychainAttributes_shouldProvideMetadata() throws {
        // Given: A keychain with labeled data
        let labeledKeychain = keychain.label("Test Data").comment("Used for unit testing")
        let key = "attributed_data"
        let value = "data_with_attributes"
        
        // When: Storing data with attributes
        try labeledKeychain.set(value, key: key)
        
        // Then: Attributes should be accessible
        let attributes = try keychain.get(key) { attributes in
            return attributes
        }
        
        XCTAssertNotNil(attributes, "Attributes should be available")
        XCTAssertEqual(attributes?.label, "Test Data", "Label should be preserved")
        XCTAssertEqual(attributes?.comment, "Used for unit testing", "Comment should be preserved")
    }
}

// MARK: - Test Helpers

extension KeychainTests {
    
    /// Helper method to generate test keys with unique identifiers
    private func testKey(_ identifier: String) -> String {
        return "test_\(identifier)_\(UUID().uuidString)"
    }
}