import Foundation
import CoreData

/// Inbox messages domain entity with CoreData support
@objc(InboxMessage)
public class InboxMessage: Entity {
    @NSManaged public var title: String
    @NSManaged public var subtitle: String
    @NSManaged public var wasReaded: Bool
}
