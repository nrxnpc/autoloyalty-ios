import Foundation
import CoreData

public extension ScopeGraphKits {
    /// Create CoreData-enabled data pipeline
    static func coreDataKit(
        userId: String,
        modelName: String,
        modelBundle: Bundle
    ) -> DataPipeline {
        let stack = CoreDataStack(userId: userId, modelName: modelName, modelBundle: modelBundle)
        let coreDataComponent = CoreDataComponent(stack: stack)
        
        return ScopeGraph()
            .register(coreDataComponent)
            .build()
    }
    
    /// Create user-specific CoreData pipeline
    static func userCoreDataKit(userId: String) -> DataPipeline {
        // Default configuration for user data
        return coreDataKit(
            userId: userId,
            modelName: "Domain",
            modelBundle: .main
        )
    }
}
