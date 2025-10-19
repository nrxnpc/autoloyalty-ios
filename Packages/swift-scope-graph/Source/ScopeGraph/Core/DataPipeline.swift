import Foundation
import CoreData

/// Data processing pipeline
/// 
/// The main interface for interacting with registered components.
/// Provides unified access to storage, caching, and processing operations.
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public struct DataPipeline: Sendable {
    private let components: [any DataComponent & Sendable]
    
    init(components: [any DataComponent & Sendable]) {
        self.components = components
    }
    
    /// Store a value using available storage components
    /// - Parameters:
    ///   - value: Value to store
    ///   - key: Storage key
    /// - Throws: Storage errors
    public func store<T: Sendable>(_ value: T, forKey key: String) async throws {
        for component in components {
            if let storageComponent = component as? any StorageComponentProtocol {
                try await storageComponent.store(value, forKey: key)
            }
        }
    }
    
    /// Retrieve a value from available storage components
    /// - Parameters:
    ///   - key: Storage key
    ///   - type: Expected value type
    /// - Returns: Retrieved value or nil if not found
    /// - Throws: Storage errors
    public func retrieve<T: Sendable>(forKey key: String, as type: T.Type) async throws -> T? {
        for component in components {
            if let storageComponent = component as? any StorageComponentProtocol {
                if let value = try await storageComponent.retrieve(forKey: key, as: type) {
                    return value
                }
            }
        }
        return nil
    }
    
    /// Remove a value from all storage components
    /// - Parameter key: Storage key to remove
    /// - Throws: Storage errors
    public func remove(forKey key: String) async throws {
        for component in components {
            if let storageComponent = component as? any StorageComponentProtocol {
                try await storageComponent.remove(forKey: key)
            }
        }
    }
    
    /// Access CoreData stack from registered CoreData component
    /// - Returns: CoreData stack instance
    /// - Note: Crashes if no CoreData component is registered
    public func coreDataStack() -> CoreDataStack {
        for component in components {
            if let coreDataComponent = component as? CoreDataComponent {
                return coreDataComponent.stack
            }
        }
        fatalError("CoreData component not found in pipeline. Register a CoreDataComponent first.")
    }
    
    /// Get all registered components
    /// - Returns: Array of registered components
    public var registeredComponents: [any DataComponent & Sendable] {
        return components
    }
}

/// Protocol for storage components
/// 
/// Defines the interface for components that provide storage capabilities.
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public protocol StorageComponentProtocol: Sendable {
    /// Store a value with the given key
    /// - Parameters:
    ///   - value: Value to store
    ///   - key: Storage key
    /// - Throws: Storage errors
    func store<T: Sendable>(_ value: T, forKey key: String) async throws
    
    /// Retrieve a value for the given key
    /// - Parameters:
    ///   - key: Storage key
    ///   - type: Expected value type
    /// - Returns: Retrieved value or nil if not found
    /// - Throws: Storage errors
    func retrieve<T: Sendable>(forKey key: String, as type: T.Type) async throws -> T?
    
    /// Remove a value for the given key
    /// - Parameter key: Storage key to remove
    /// - Throws: Storage errors
    func remove(forKey key: String) async throws
}