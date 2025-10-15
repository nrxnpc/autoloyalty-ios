import CoreData
import Combine

// MARK: - FetchedObject (For a single entity)

/// An observable object that wraps an `NSFetchedResultsController` to fetch and monitor
/// a single Core Data managed object.
///
/// It is designed to replace `@FetchRequest` for a single entity in a SwiftUI view,
/// providing more control and a cleaner architecture. It notifies observers whenever the
/// underlying object is created, updated, or deleted.
@MainActor
@dynamicMemberLookup
public final class FetchedObject<T: NSManagedObject & Equatable>: NSObject, ObservableObject, @preconcurrency NSFetchedResultsControllerDelegate {
    
    /// The fetched object. This property is published, so SwiftUI views will be updated
    /// automatically when the object changes.
    @Published private(set) public var object: T?
    nonisolated(unsafe) private(set) var objectPublisher: Published<T?>.Publisher!
    
    private let fetchRequest: NSFetchRequest<T>
    private var controller: NSFetchedResultsController<T>?
    
    /// Initializes the fetcher with a specific fetch request.
    ///
    /// The fetch request should be configured to find a single object (e.g., using a unique predicate).
    /// The fetch limit will be automatically set to 1. Observation will not begin until
    /// `startObserving(context:)` is called.
    ///
    /// - Parameter fetchRequest: The `NSFetchRequest` used to find the object.
    public init(_ fetchRequest: NSFetchRequest<T>, context: NSManagedObjectContext? = nil) {
        // Ensure the fetch request is configured to retrieve only one object for predictability.
        fetchRequest.fetchLimit = 1
        self.fetchRequest = fetchRequest
        super.init()
        self.objectPublisher = $object
        
        if let context {
            startObserving(context: context)
        }
    }
    
    /// Provides direct access to the properties of the wrapped managed object.
    ///
    /// This allows you to write `fetchedObject.name` instead of `fetchedObject.object?.name`.
    public subscript<Value>(dynamicMember keyPath: KeyPath<T, Value>) -> Value? {
        return object?[keyPath: keyPath]
    }
    
    /// Starts observing the Core Data context for changes to the object.
    ///
    /// This method should be called from a view's lifecycle method, such as `.task` or `.onAppear`,
    /// once the `managedObjectContext` is available from the environment. Calling it multiple times
    /// has no effect.
    ///
    /// - Parameter context: The `NSManagedObjectContext` to observe.
    public func startObserving(context: NSManagedObjectContext) {
        // Avoid re-initializing if already started.
        guard self.controller == nil else { return }
        
        let frc = NSFetchedResultsController(
            fetchRequest: self.fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        self.controller = frc
        
        do {
            try frc.performFetch()
            self.object = frc.fetchedObjects?.first
        } catch {
            // In a production app, this error should be logged or handled more gracefully.
            print("Failed to fetch object: \(error.localizedDescription)")
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    /// Called by the `NSFetchedResultsController` when its content has changed.
    ///
    /// This method updates the `object` property, which in turn notifies any subscribing
    /// SwiftUI views to re-render.
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.object = controller.fetchedObjects?.first as? T
    }
}

// MARK: - Publisher Protocol Implementation

extension FetchedObject: Publisher {
    public typealias Output = T?
    public typealias Failure = Never
    
    nonisolated public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        // TODO: Main actor-isolated property 'objectPublisher' can not be referenced from a nonisolated context
        objectPublisher.receive(subscriber: subscriber)
    }
}

// MARK: - FetchedObjects (For a collection of entities)

/// An observable object that wraps an `NSFetchedResultsController` to fetch and monitor
/// a collection of Core Data managed objects.
///
/// It serves as a reusable replacement for `@FetchRequest` for collections, allowing for
/// better testability and separation of concerns.
@MainActor
public final class FetchedObjects<T: NSManagedObject & Equatable & Identifiable>: NSObject, ObservableObject, @preconcurrency NSFetchedResultsControllerDelegate {
    
    /// The array of fetched objects. This property is published, so SwiftUI views will
    /// update when the collection changes.
    @Published private(set) public var objects: [T] = []
    
    /// A publisher for the array of objects, used to conform to the `Publisher` protocol.
    /// This is marked `nonisolated(unsafe)` to bridge with the non-isolated Combine protocol.
    /// Access is safe because `Published` on a `@MainActor` class dispatches updates to the main thread.
    nonisolated(unsafe) private(set) var objectsPublisher: Published<[T]>.Publisher!
    
    private let fetchRequest: NSFetchRequest<T>
    private var controller: NSFetchedResultsController<T>?
    
    /// Initializes the fetcher with a specific fetch request and an optional context.
    ///
    /// If a `context` is provided, observation will begin immediately. Otherwise, you must
    /// call `startObserving(context:)` manually.
    ///
    /// - Parameters:
    ///   - fetchRequest: The `NSFetchRequest` used to find the objects.
    ///   - context: An optional `NSManagedObjectContext` to begin observing immediately.
    public init(_ fetchRequest: NSFetchRequest<T>, context: NSManagedObjectContext? = nil) {
        self.fetchRequest = fetchRequest
        super.init()
        self.objectsPublisher = $objects
        
        if let context {
            startObserving(context: context)
        }
    }
    
    /// Starts observing the Core Data context for changes to the collection.
    ///
    /// This method should be called from a view's lifecycle method, such as `.task` or `.onAppear`.
    /// Calling it multiple times has no effect.
    ///
    /// - Parameter context: The `NSManagedObjectContext` to observe.
    public func startObserving(context: NSManagedObjectContext) {
        // Avoid re-initializing if already started.
        guard self.controller == nil else { return }
        
        let frc = NSFetchedResultsController(
            fetchRequest: self.fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        self.controller = frc
        
        do {
            try frc.performFetch()
            self.objects = frc.fetchedObjects ?? []
        } catch {
            print("Failed to fetch objects: \(error.localizedDescription)")
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    /// Called by the `NSFetchedResultsController` when its content has changed.
    /// This method updates the `objects` array, notifying any subscribing SwiftUI views.
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.objects = controller.fetchedObjects as? [T] ?? []
    }
}

// MARK: - Publisher Protocol Implementation

// MARK: - RandomAccessCollection Conformance

extension FetchedObjects: RandomAccessCollection {
    public typealias Element = T
    public typealias Index = Int
    
    public var startIndex: Int { objects.startIndex }
    public var endIndex: Int { objects.endIndex }
    
    public subscript(position: Int) -> T {
        objects[position]
    }
}

// MARK: - Publisher Conformance

extension FetchedObjects: Publisher {
    public typealias Output = [T]
    public typealias Failure = Never
    
    nonisolated public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        objectsPublisher.receive(subscriber: subscriber)
    }
}
