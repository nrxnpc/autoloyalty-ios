import Foundation
import CoreData

/// CoreData component for ScopeGraph pipeline
public struct CoreDataComponent: DataComponent, Sendable {
    public typealias Input = CoreDataOperation
    public typealias Output = CoreDataResult
    
    public let identifier = "coredata"
    public let stack: CoreDataStack
    
    public init(stack: CoreDataStack) {
        self.stack = stack
    }
    
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

/// CoreData operations
public enum CoreDataOperation {
    case fetch(NSFetchRequest<NSManagedObject>)
    case save
    case delete(NSManagedObject)
    case create(String)
}

/// CoreData results
public enum CoreDataResult {
    case entities([NSManagedObject])
    case entity(NSManagedObject)
    case success
}