import Foundation
import CoreData

/// Support messages domain entity with CoreData support
@objc(SupportMessage)
public class SupportMessage: Entity {
    @NSManaged public var text: String
    @NSManaged public var isOwned: Bool
}

extension SupportMessage {
    private static func create(from text: String, isOwned: Bool, in context: NSManagedObjectContext) {
        let message = SupportMessage(context: context)
        message.sync.isDraft = true
        message.text = text
        message.isOwned = isOwned
    }
}
