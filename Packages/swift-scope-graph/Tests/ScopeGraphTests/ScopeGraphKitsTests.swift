import XCTest
@testable import ScopeGraph

/// Tests for ScopeGraph kits including CoreData kits
final class ScopeGraphKitsTests: XCTestCase {
    
    /// Test CoreData kit creation
    func test_coreDataKit_shouldCreatePipeline() {
        // Given: CoreData kit parameters
        let userId = "test_user"
        let modelName = "TestModel"
        let bundle = Bundle.main
        
        // When: Creating CoreData kit
        let pipeline = ScopeGraphKits.coreDataKit(
            userId: userId,
            modelName: modelName,
            modelBundle: bundle
        )
        
        // Then: Pipeline should be created
        XCTAssertNotNil(pipeline)
    }
    
    /// Test user CoreData kit creation
    func test_userCoreDataKit_shouldCreatePipeline() {
        // Given: User ID
        let userId = "test_user"
        
        // When: Creating user CoreData kit
        let pipeline = ScopeGraphKits.userCoreDataKit(userId: userId)
        
        // Then: Pipeline should be created with defaults
        XCTAssertNotNil(pipeline)
    }
    
    /// Test existing kits still work
    func test_existingKits_shouldStillWork() {
        // Given: Existing kit methods
        let userDataKit = ScopeGraphKits.userDataKit()
        let mediaKit = ScopeGraphKits.mediaKit()
        let apiCacheKit = ScopeGraphKits.apiCacheKit()
        
        // When: Creating kits
        // Then: All kits should be available
        XCTAssertNotNil(userDataKit)
        XCTAssertNotNil(mediaKit)
        XCTAssertNotNil(apiCacheKit)
    }
}