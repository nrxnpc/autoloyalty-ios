import Foundation
import CoreData

extension SupportMessage {
    /// Fetch all messages sorted by date
    static func allMessagesSortedByCreatedDate() -> NSFetchRequest<SupportMessage> {
        let request = NSFetchRequest<SupportMessage>(entityName: "SupportMessage")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
    
    /// Fetch all drafts
    static func allDrafts() -> NSFetchRequest<SupportMessage> {
        let request = NSFetchRequest<SupportMessage>(entityName: "SupportMessage")
        request.predicate = NSPredicate(format: "isDraft == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
}

extension SupportMessage {
    public static func byID(_ id: String) -> NSFetchRequest<SupportMessage> {
        let request = NSFetchRequest<SupportMessage>(entityName: "SupportMessage")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
    
    public static func byExternalID(_ externalID: String) -> NSFetchRequest<SupportMessage> {
        let request = NSFetchRequest<SupportMessage>(entityName: "SupportMessage")
        request.predicate = NSPredicate(format: "sync.externalID == %@", externalID)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
}
