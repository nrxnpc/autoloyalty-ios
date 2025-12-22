import Foundation
import CoreData

/// Inbox messages domain entity with CoreData support
@objc(InboxMessage)
public class InboxMessage: Entity {
    @NSManaged public var title: String
    @NSManaged public var subtitle: String
    @NSManaged public var wasReaded: Bool
}

extension InboxMessage {
    static func createOrUpdate(from raw: RestEndpoint.NewsArticle, in context: NSManagedObjectContext) {
        let request = InboxMessage.byExternalID(raw.id)
        if let existing = try? context.fetch(request).first {
            existing.title = raw.title
            existing.subtitle = raw.content
            
            if let publishedAt = raw.publishedAt, let published = ISO8601DateFormatter().date(from: publishedAt) {
                existing.createdAt = published
            } else if let date = ISO8601DateFormatter().date(from: raw.createdAt) {
                existing.createdAt = date
            }
        } else {
            create(from: raw, in: context)
        }
    }
    
    private static func create(from raw: RestEndpoint.NewsArticle, in context: NSManagedObjectContext) {
        let inbox = InboxMessage(context: context)
        inbox.sync.externalID = raw.id
        inbox.title = raw.title
        inbox.subtitle = raw.content
        inbox.createdAt = ISO8601DateFormatter().date(from: raw.createdAt) ?? .now
    }
}
