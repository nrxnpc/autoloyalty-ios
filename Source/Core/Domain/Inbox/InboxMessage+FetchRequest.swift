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

extension InboxMessage {
    public static func byID(_ id: String) -> NSFetchRequest<InboxMessage> {
        let request = NSFetchRequest<InboxMessage>(entityName: "InboxMessage")
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return request
    }
    
    public static func byExternalID(_ externalID: String) -> NSFetchRequest<InboxMessage> {
        let request = NSFetchRequest<InboxMessage>(entityName: "InboxMessage")
        request.predicate = NSPredicate(format: "sync.externalID == %@", externalID)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "sync.externalID", ascending: true)]
        return request
    }
}
