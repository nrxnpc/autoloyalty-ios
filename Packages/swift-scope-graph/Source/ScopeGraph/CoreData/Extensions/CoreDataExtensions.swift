import CoreData
import Foundation

// MARK: - ScopeGraph CoreData DSL

public extension DataPipeline {
    /// CoreData operations DSL
    func coreData() -> CoreDataDSL {
        // Access CoreData component through pipeline
        // This is a simplified implementation
        fatalError("CoreData DSL access needs pipeline component lookup")
    }
}

/// CoreData DSL for fluent operations
public struct CoreDataDSL {
    private let component: CoreDataComponent
    
    init(component: CoreDataComponent) {
        self.component = component
    }
    
    /// Fetch entities with fluent builder
    public func fetch<T: NSManagedObject>(_ type: T.Type) -> CoreDataFetchBuilder<T> {
        CoreDataFetchBuilder<T>(component: component)
    }
    
    /// Create new entity
    public func create<T: NSManagedObject>(_ type: T.Type) async throws -> T {
        let result = try await component.process(.create(String(describing: type)))
        guard case .entity(let entity) = result else {
            throw CoreDataError.creationFailed
        }
        return entity as! T
    }
    
    /// Save changes
    public func save() async throws {
        _ = try await component.process(.save)
    }
    
    /// Delete entity
    public func delete<T: NSManagedObject>(_ entity: T) async throws {
        _ = try await component.process(.delete(entity))
    }
}

/// Fluent fetch builder for CoreData queries
public class CoreDataFetchBuilder<T: NSManagedObject> {
    private let component: CoreDataComponent
    private var predicate: NSPredicate?
    private var sortDescriptors: [NSSortDescriptor] = []
    private var fetchLimit: Int = 0
    
    init(component: CoreDataComponent) {
        self.component = component
    }
    
    /// Add predicate filter
    public func `where`(_ predicate: NSPredicate) -> Self {
        self.predicate = predicate
        return self
    }
    
    /// Add sort descriptor
    public func sorted(by keyPath: String, ascending: Bool = true) -> Self {
        sortDescriptors.append(NSSortDescriptor(key: keyPath, ascending: ascending))
        return self
    }
    
    /// Limit results
    public func limit(_ count: Int) -> Self {
        self.fetchLimit = count
        return self
    }
    
    /// Execute fetch request
    public func execute() async throws -> [T] {
        let request = NSFetchRequest<NSManagedObject>(entityName: String(describing: T.self))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        if fetchLimit > 0 {
            request.fetchLimit = fetchLimit
        }
        
        let result = try await component.process(.fetch(request))
        guard case .entities(let entities) = result else {
            throw CoreDataError.fetchFailed
        }
        return entities.compactMap { $0 as? T }
    }
    
    /// Get first result
    public func first() async throws -> T? {
        return try await limit(1).execute().first
    }
}

/// CoreData errors
public enum CoreDataError: Error {
    case creationFailed
    case fetchFailed
    case saveFailed
}