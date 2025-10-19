import Foundation
import CoreData

/// CoreData integration component for persistent storage
/// 
/// Provides seamless CoreData integration with the ScopeGraph pipeline.
/// Supports user-specific databases, in-memory storage for testing,
/// and automatic migration handling.
/// 
/// Features:
/// - User-specific SQLite databases
/// - In-memory storage for testing
/// - Automatic migration and error recovery
/// - Thread-safe operations
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public struct CoreDataComponent: DataComponent, Sendable {
    public typealias Input = CoreDataOperation
    public typealias Output = CoreDataResult
    
    public let identifier = "coredata"
    public let stack: CoreDataStack
    
    /// Initialize CoreData component with existing stack
    /// - Parameter stack: Configured CoreData stack
    public init(stack: CoreDataStack) {
        self.stack = stack
    }
    
    /// Process CoreData operations
    /// - Parameter input: CoreData operation to perform
    /// - Returns: Operation result
    /// - Throws: CoreData errors
    public func process(_ input: CoreDataOperation) async throws -> CoreDataResult {
        switch input {
        case .fetch(let request):
            let results = try stack.viewContext.fetch(request)
            return .entities(results)
        case .save:
            try await stack.save()
            return .success
        case .delete(let object):
            stack.viewContext.delete(object)
            return .success
        case .create(let entityName):
            let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: stack.viewContext)
            return .entity(entity)
        }
    }
}

/// CoreData operation types
/// 
/// Defines the types of operations that can be performed on CoreData.
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public enum CoreDataOperation {
    case fetch(NSFetchRequest<NSManagedObject>)
    case save
    case delete(NSManagedObject)
    case create(String)
}

/// CoreData operation results
/// 
/// Represents the result of a CoreData operation.
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public enum CoreDataResult {
    case entities([NSManagedObject])
    case entity(NSManagedObject)
    case success
}

// MARK: - Sendable Conformance
extension CoreDataOperation: @unchecked Sendable {}
extension CoreDataResult: @unchecked Sendable {}
