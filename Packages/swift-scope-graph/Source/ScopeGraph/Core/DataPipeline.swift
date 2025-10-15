import Foundation
import CoreData

/// Data processing pipeline
public struct DataPipeline {
    private let components: [any DataComponent]
    
    init(components: [any DataComponent]) {
        self.components = components
    }
    
    public func store<T>(_ value: T, forKey key: String) async throws {
        for component in components {
            if let storageComponent = component as? any StorageComponentProtocol {
                try await storageComponent.store(value, forKey: key)
            }
        }
    }
    
    public func retrieve<T>(forKey key: String, as type: T.Type) async throws -> T? {
        for component in components {
            if let storageComponent = component as? any StorageComponentProtocol {
                if let value = try await storageComponent.retrieve(forKey: key, as: type) {
                    return value
                }
            }
        }
        return nil
    }
    
    public func remove(forKey key: String) async throws {
        for component in components {
            if let storageComponent = component as? any StorageComponentProtocol {
                try await storageComponent.remove(forKey: key)
            }
        }
    }
    
    /// Access CoreData stack
    public func coreDataStack() -> CoreDataStack {
        for component in components {
            if let coreDataComponent = component as? CoreDataComponent {
                return coreDataComponent.stack
            }
        }
        fatalError("CoreData component not found in pipeline")
    }
}

/// Protocol for storage components
public protocol StorageComponentProtocol {
    func store<T>(_ value: T, forKey key: String) async throws
    func retrieve<T>(forKey key: String, as type: T.Type) async throws -> T?
    func remove(forKey key: String) async throws
}