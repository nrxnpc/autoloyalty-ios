import CoreData
#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

#if canImport(UIKit) || canImport(AppKit)
/// A concurrency-based loader for observing a single Core Data entity and providing its image data as an asynchronous stream.
/// This actor encapsulates the `NSFetchedResultsController` to safely bridge Core Data's delegate pattern with Swift Concurrency.
@MainActor
final public class AttachmentLoader: NSObject, @preconcurrency NSFetchedResultsControllerDelegate {
    private var fetchedResultsController: NSFetchedResultsController<Account>?
    private var continuation: AsyncStream<PlatformImage?>.Continuation?

    /// Provides a continuous stream of `UIImage?` objects for a given account.
    ///
    /// The stream immediately yields the current image (or nil) and then provides new images
    /// whenever the underlying `Account` or its `image` attachment changes in Core Data.
    /// The stream handles its own cancellation and cleans up the Core Data observer.
    ///
    /// - Parameters:
    ///   - accountID: The ID of the `Account` to observe.
    ///   - context: The `NSManagedObjectContext` to perform the fetch in.
    /// - Returns: An `AsyncStream` that emits `UIImage?` values.
    public func imageStream(for accountID: String, in context: NSManagedObjectContext) -> AsyncStream<PlatformImage?> {
        AsyncStream { continuation in
            self.continuation = continuation
            
            let request = Account.byID(accountID)
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            fetchedResultsController?.delegate = self
            
            do {
                try fetchedResultsController?.performFetch()
                // Yield the initial value immediately after the first fetch.
                updateImage()
            } catch {
                // If fetch fails, yield nil and log the error.
                continuation.yield(nil)
                // In a real app, you would log this error.
                print("Failed to fetch account: \(error)")
            }

            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in
                    self?.fetchedResultsController?.delegate = nil
                    self?.fetchedResultsController = nil
                    self?.continuation = nil
                }
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    /// This delegate method is called by Core Data whenever the observed object changes.
    nonisolated public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Task { @MainActor in
            updateImage()
        }
    }
    
    // MARK: - Private Helpers
    
    /// Fetches the latest attachment data, processes it into a UIImage, and yields it to the stream.
    private func updateImage() {
        guard let account = fetchedResultsController?.fetchedObjects?.first,
              let imageData = account.image.native ?? account.image.raw else {
            continuation?.yield(nil as PlatformImage?)
            return
        }
        
        // Create the UIImage from data. This is a lightweight operation
        // for typical image sizes and can be done synchronously here,
        // as we are already on the main actor.
        let image = PlatformImage(data: imageData)
        continuation?.yield(image)
    }
}
#else
/// Empty AttachmentLoader for testing when UI frameworks are not available.
/// Provides the same interface as the real AttachmentLoader for documentation and testing purposes.
@MainActor
final public class AttachmentLoader {
    
    /// Provides a continuous stream of Data objects for a given account.
    /// 
    /// **Testing Implementation:** Returns empty stream for testing purposes.
    /// **Real Implementation:** Observes Core Data changes and yields platform images.
    ///
    /// - Parameters:
    ///   - accountID: The ID of the `Account` to observe.
    ///   - context: The `NSManagedObjectContext` to perform the fetch in.
    /// - Returns: An `AsyncStream` that emits `Data?` values for testing.
    public func imageStream(for accountID: String, in context: NSManagedObjectContext) -> AsyncStream<Data?> {
        AsyncStream { continuation in
            // Testing implementation: yield nil and finish
            continuation.yield(nil)
            continuation.finish()
        }
    }
}
#endif
