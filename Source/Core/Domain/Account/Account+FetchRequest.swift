import Foundation
import CoreData
import SwiftUI

// MARK: - Account Fetch Request Factories

public extension Account {

    // MARK: - Sort Keys Enum

    enum SortKey: String {
        case name
        case email
        case createdAt
    }
    
    // MARK: - Predicate Factories
    
    static func idPredicate(for id: String) -> NSPredicate {
        NSPredicate(format: "id == %@", id)
    }
    
    static func externalIDPredicate(for externalID: String) -> NSPredicate {
        NSPredicate(format: "sync.externalID == %@", externalID)
    }
    
    static func matchingPredicate(for query: String) -> NSPredicate {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return NSPredicate(value: true)
        }
        
        return NSPredicate(
            format: "name CONTAINS[cd] %@ OR nickname CONTAINS[cd] %@ OR email CONTAINS[cd] %@",
            query, query, query
        )
    }
    
    static func ghostAccountsPredicate() -> NSPredicate {
        NSPredicate(format: "id == 'ghost' OR id == 'guest'")
    }

    // MARK: - NSFetchRequest Factories

    static func createFetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }
    
    static func all(sortedBy key: SortKey, ascending: Bool = true) -> NSFetchRequest<Account> {
        let request = createFetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: key.rawValue, ascending: ascending)
        ]
        return request
    }
    
    static func byID(_ id: String) -> NSFetchRequest<Account> {
        let request = createFetchRequest()
        request.predicate = idPredicate(for: id)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return request
    }
    
    static func byExternalID(_ externalID: String) -> NSFetchRequest<Account> {
        let request = createFetchRequest()
        request.predicate = externalIDPredicate(for: externalID)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "sync.externalID", ascending: true)]
        return request
    }
    
    static func matching(query: String, sortedBy key: SortKey = .name, ascending: Bool = true) -> NSFetchRequest<Account> {
        let request = all(sortedBy: key, ascending: ascending)
        request.predicate = matchingPredicate(for: query)
        return request
    }

    static func ghostAccounts(sortedBy key: SortKey = .createdAt, ascending: Bool = false) -> NSFetchRequest<Account> {
        let request = all(sortedBy: key, ascending: ascending)
        request.predicate = ghostAccountsPredicate()
        return request
    }
}
