import Foundation
import CoreData
import SwiftUI

// MARK: - Attachment Fetch Request Factories

public extension Attachment {

    /// Provides convenient, pre-configured fetch requests for the Attachment entity.
    /// This helps to keep SwiftUI views clean and encapsulates Core Data query logic.
    ///
    /// ### Usage in SwiftUI
    ///
    /// #### Fetching attachments that need to be downloaded
    ///
    /// ```swift
    /// struct DownloadQueueView: View {
    ///     @FetchRequest(fetchRequest: Attachment.notLoaded())
    ///     private var attachmentsToDownload: FetchedResults<Attachment>
    ///
    ///     var body: some View {
    ///         List(attachmentsToDownload) { attachment in
    ///             Text(attachment.sourceURL?.absoluteString ?? "No URL")
    ///         }
    ///     }
    /// }
    /// ```

    // MARK: - Sort Keys Enum

    /// A type-safe way to specify sort keys for Attachment fetch requests.
    /// The raw value of each case must match the property name on the Attachment entity.
    enum SortKey: String {
        case createdAt
    }

    // MARK: - Predicate Factories

    /// Creates a predicate to find an attachment matching a specific ID.
    static func idPredicate(for id: String) -> NSPredicate {
        NSPredicate(format: "id == %@", id)
    }

    /// A predicate to find attachments that have a `sourceURL` but no local data yet.
    /// These are candidates for downloading.
    static func notLoadedPredicate() -> NSPredicate {
        NSPredicate(format: "sourceURL != nil AND raw == nil AND native == nil")
    }

    /// A predicate to find attachments that have local data but no `sourceURL`.
    /// These are candidates for uploading/publishing.
    static func notPublishedPredicate() -> NSPredicate {
        NSPredicate(format: "sourceURL == nil AND (raw != nil OR native != nil)")
    }

    /// A predicate to find attachments that have downloaded raw data but not the optimized native version.
    /// These are candidates for processing (e.g., resizing an image).
    static func notOptimizedPredicate() -> NSPredicate {
        NSPredicate(format: "sourceURL != nil AND raw != nil AND native == nil")
    }
    
    /// A predicate to find attachments that can have their `raw` data cleaned up.
    /// These are attachments where both `raw` and `native` data exist.
    /// - Note: The final check (`sourceHash == calculateNativeHash()`) must be done in Swift code after fetching, as it cannot be evaluated by Core Data.
    static func readyToCleanPredicate() -> NSPredicate {
        NSPredicate(format: "sourceURL != nil AND raw != nil AND native != nil")
    }


    // MARK: - NSFetchRequest Factories

    /// Creates a base fetch request for the `Attachment` entity.
    static func createFetchRequest() -> NSFetchRequest<Attachment> {
        return NSFetchRequest<Attachment>(entityName: "Attachment")
    }

    /// Returns a fully configured `NSFetchRequest` for fetching all attachments.
    ///
    /// - Parameters:
    ///   - key: The `SortKey` to sort the results by.
    ///   - ascending: A boolean indicating the sort direction.
    /// - Returns: A configured `NSFetchRequest` instance.
    static func all(sortedBy key: SortKey = .createdAt, ascending: Bool = false) -> NSFetchRequest<Attachment> {
        let request = createFetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: key.rawValue, ascending: ascending)
        ]
        return request
    }

    /// Returns a fully configured `NSFetchRequest` for fetching a single attachment by its ID.
    ///
    /// - Parameter id: The unique identifier of the attachment.
    /// - Returns: A configured `NSFetchRequest` instance.
    static func byID(_ id: String) -> NSFetchRequest<Attachment> {
        let request = createFetchRequest()
        request.predicate = idPredicate(for: id)
        request.fetchLimit = 1
        return request
    }

    /// Returns a fetch request for attachments that need to be downloaded from their `sourceURL`.
    ///
    /// - Parameters:
    ///   - key: The `SortKey` to sort the results by.
    ///   - ascending: Sort direction. Defaults to `true` to process older items first.
    /// - Returns: A configured `NSFetchRequest` instance.
    static func notLoaded(sortedBy key: SortKey = .createdAt, ascending: Bool = true) -> NSFetchRequest<Attachment> {
        let request = all(sortedBy: key, ascending: ascending)
        request.predicate = notLoadedPredicate()
        return request
    }

    /// Returns a fetch request for attachments that were created locally and need to be published.
    ///
    /// - Parameters:
    ///   - key: The `SortKey` to sort the results by.
    ///   - ascending: Sort direction. Defaults to `true` to process older items first.
    /// - Returns: A configured `NSFetchRequest` instance.
    static func notPublished(sortedBy key: SortKey = .createdAt, ascending: Bool = true) -> NSFetchRequest<Attachment> {
        let request = all(sortedBy: key, ascending: ascending)
        request.predicate = notPublishedPredicate()
        return request
    }

    /// Returns a fetch request for downloaded attachments that need optimization (e.g., image resizing).
    ///
    /// - Parameters:
    ///   - key: The `SortKey` to sort the results by.
    ///   - ascending: Sort direction. Defaults to `true` to process older items first.
    /// - Returns: A configured `NSFetchRequest` instance.
    static func notOptimized(sortedBy key: SortKey = .createdAt, ascending: Bool = true) -> NSFetchRequest<Attachment> {
        let request = all(sortedBy: key, ascending: ascending)
        request.predicate = notOptimizedPredicate()
        return request
    }
    
    /// Returns a fetch request for attachments whose raw data can be potentially cleaned up.
    ///
    /// - Parameters:
    ///   - key: The `SortKey` to sort the results by.
    ///   - ascending: Sort direction. Defaults to `true` to process older items first.
    /// - Returns: A configured `NSFetchRequest` instance.
    static func readyToClean(sortedBy key: SortKey = .createdAt, ascending: Bool = true) -> NSFetchRequest<Attachment> {
        let request = all(sortedBy: key, ascending: ascending)
        request.predicate = readyToCleanPredicate()
        return request
    }
}
