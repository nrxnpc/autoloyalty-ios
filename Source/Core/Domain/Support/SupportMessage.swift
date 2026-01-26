import Foundation
import CoreData

/// Support messages domain entity with CoreData support
@objc(SupportMessage)
public class SupportMessage: Entity {
    @NSManaged public var text: String
    @NSManaged public var isOwned: Bool
}

extension SupportMessage {
    static func createOrUpdate(from raw: RestEndpoint.SupportMessage, isOwned: Bool, in context: NSManagedObjectContext) {
        let request = SupportMessage.byExternalID(raw.id)
        if let existing = try? context.fetch(request).first {
            existing.text = raw.content
            existing.isOwned = isOwned
            if let timestamp = ISO8601DateFormatter().date(from: raw.timestamp ?? "") {
                existing.createdAt = timestamp
            }
        } else {
            create(from: raw, isOwned: isOwned, in: context)
        }
    }
    
    private static func create(from raw: RestEndpoint.SupportMessage, isOwned: Bool, in context: NSManagedObjectContext) {
        let message = SupportMessage(context: context)
        message.sync.externalID = raw.id
        message.text = raw.content
        message.isOwned = isOwned
        message.createdAt = ISO8601DateFormatter().date(from: raw.timestamp ?? "") ?? .now
    }
}
