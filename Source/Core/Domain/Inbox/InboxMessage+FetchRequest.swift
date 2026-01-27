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
    
    /// Fetch all unread messages from support team
    static func unreadSupportMessages() -> NSFetchRequest<InboxMessage> {
        let request = NSFetchRequest<InboxMessage>(entityName: "InboxMessage")
        request.predicate = NSPredicate(format: "wasReaded == NO AND type == %d", InboxMessage.MessageType.supportMessage.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
    
    /// Fetch all readed messages from support team
    static func readSupportMessagesOlderThan(hours: Int) -> NSFetchRequest<InboxMessage> {
        let request = NSFetchRequest<InboxMessage>(entityName: "InboxMessage")
        let date = Calendar.current.date(byAdding: .hour, value: -hours, to: .now)!
        request.predicate = NSPredicate(
            format: "wasReaded == YES AND type == %d AND createdAt < %@",
            InboxMessage.MessageType.supportMessage.rawValue,
            date as NSDate
        )
        return request
    }
    
    /// Fetch all messages sorted by date
    static func allMessagesSortedByCreatedDate() -> NSFetchRequest<InboxMessage> {
        let request = NSFetchRequest<InboxMessage>(entityName: "InboxMessage")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
    
    /// Fetch messages filtered by search text
    static func messagesFilteredBy(searchText: String) -> NSFetchRequest<InboxMessage> {
        let request = NSFetchRequest<InboxMessage>(entityName: "InboxMessage")
        if !searchText.isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR subtitle CONTAINS[cd] %@", searchText, searchText)
        }
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
}

extension InboxMessage {
    public static func byID(_ id: String) -> NSFetchRequest<InboxMessage> {
        let request = NSFetchRequest<InboxMessage>(entityName: "InboxMessage")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
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
