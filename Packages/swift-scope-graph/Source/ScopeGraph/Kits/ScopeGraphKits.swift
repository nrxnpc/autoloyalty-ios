import Foundation
import CoreData

/// Ready-to-use component kits for common use cases
public struct ScopeGraphKits {
    /// User data management kit with CoreData
    public static func userDataKit(modelBuilder: (() -> NSManagedObjectModel)? = nil) -> DataPipeline {
        guard let model = modelBuilder?() else {
            fatalError()
        }
        let coreDataStack = CoreDataStack.inMemory(model: model)
        let coreDataComponent = CoreDataComponent(stack: coreDataStack)
        
        return ScopeGraph()
            .register(coreDataComponent)
            .register(StorageModule.memory())
            .register(StorageModule.secure(service: "com.notemess"))
            .build()
    }
}
