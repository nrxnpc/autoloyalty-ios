import Foundation
import CoreData

extension BalanceTransaction {
    /// Fetch all messages sorted by date
    static func allTransactions() -> NSFetchRequest<BalanceTransaction> {
        let request = NSFetchRequest<BalanceTransaction>(entityName: "BalanceTransaction")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
    
    static func byID(_ id: String) -> NSFetchRequest<BalanceTransaction> {
        let request = NSFetchRequest<BalanceTransaction>(entityName: "BalanceTransaction")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
    
    static func byExternalID(_ externalID: String) -> NSFetchRequest<BalanceTransaction> {
        let request = NSFetchRequest<BalanceTransaction>(entityName: "BalanceTransaction")
        request.predicate = NSPredicate(format: "sync.externalID == %@", externalID)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "sync.externalID", ascending: true)]
        return request
    }
}
