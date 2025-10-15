import Foundation
import CoreData

/// CoreData stack with user-specific databases
public final class CoreDataStack: @unchecked Sendable {
    private var userId: String
    private var _persistentContainer: NSPersistentContainer?
    private let modelName: String
    private let modelBundle: Bundle?
    private var isInMemory: Bool
    private let customModel: NSManagedObjectModel?
    
    public init(userId: String, modelName: String, modelBundle: Bundle) {
        self.userId = userId
        self.modelName = modelName
        self.modelBundle = modelBundle
        self.isInMemory = false
        self.customModel = nil
    }
    
    private init(userId: String, modelName: String, model: NSManagedObjectModel?, inMemory: Bool) {
        self.userId = userId
        self.modelName = modelName
        self.modelBundle = nil
        self.isInMemory = inMemory
        self.customModel = model
    }
    
    /// Create in-memory CoreData stack with custom model
    public static func inMemory(userId: String = "test_user", modelName: String = "InMemoryModel", model: NSManagedObjectModel) -> CoreDataStack {
        return CoreDataStack(
            userId: userId,
            modelName: modelName,
            model: model,
            inMemory: true
        )
    }
    
    public var persistentContainer: NSPersistentContainer {
        if let container = _persistentContainer {
            return container
        }
        
        let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
        
        if isInMemory {
            let storeDescription = NSPersistentStoreDescription()
            storeDescription.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [storeDescription]
        } else {
            let storeURL = databaseURL
            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            storeDescription.type = NSSQLiteStoreType
            container.persistentStoreDescriptions = [storeDescription]
            debugPrint("[DEBUG][ScopeGraph] Created SQLite store at \(databaseURL)")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                // Handle migration errors by removing old store and recreating
                if error.localizedDescription.contains("migration") {
                    self.handleMigrationError(container: container)
                } else {
                    fatalError("[ScopeGraph] CoreData error: \(error)")
                }
            }
        }
        
        _persistentContainer = container
        return container
    }
    
    public var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    public func save() async throws {
        let context = viewContext
        if context.hasChanges {
            try await context.perform {
                try context.save()
            }
        }
    }
    
    public func switchUser(to userId: String, inMemory: Bool = true) {
        // Save current context if it has changes
        if let container = _persistentContainer, !inMemory {
            let context = container.viewContext
            if context.hasChanges {
                try? context.save()
            }
        }
        
        self.isInMemory = inMemory
        
        // Clear the container to force recreation with new user database
        _persistentContainer = nil
        self.userId = userId
    }
    
    private var databaseURL: URL {
        let cacheKey = CacheKey(userId)
        let filename = "\(cacheKey.value).sqlite"
        return documentsDirectory.appendingPathComponent(filename)
    }
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var managedObjectModel: NSManagedObjectModel {
        // Use custom model if provided
        if let customModel = customModel {
            return customModel
        }
        
        // Load from bundle
        guard let modelBundle = modelBundle,
              let modelURL = modelBundle.url(forResource: modelName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load \(modelName).xcdatamodeld")
        }
        return model
    }
    
    private func handleMigrationError(container: NSPersistentContainer) {
        // Remove old store files when migration fails
        let storeURL = databaseURL
        let fileManager = FileManager.default
        
        // Remove main database file and related files
        let filesToRemove = [
            storeURL,
            storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal"),
            storeURL.deletingPathExtension().appendingPathExtension("sqlite-shm")
        ]
        
        for fileURL in filesToRemove {
            try? fileManager.removeItem(at: fileURL)
        }
        
        // Recreate store
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.type = NSSQLiteStoreType
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to recreate CoreData store: \(error)")
            }
            print("[ScopeGraph] Database \(storeURL.lastPathComponent) was re-created.")
        }
    }
}
