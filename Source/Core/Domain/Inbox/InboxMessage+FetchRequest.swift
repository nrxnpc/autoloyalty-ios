import Foundation
import CoreData

extension InboxMessage {
    /// Fetch all unread messages
    static func unreadMessages() -> NSFetchRequest<InboxMessage> {
        let request = NSFetchRequest<InboxMessage>(entityName: "InboxMessage")
        request.predicate = NSPredicate(format: "wasReaded == NO")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
    
    /// Fetch all messages sorted by date
    static func allMessagesSortedByCreatedDate() -> NSFetchRequest<InboxMessage> {
        let request = NSFetchRequest<InboxMessage>(entityName: "InboxMessage")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
}
