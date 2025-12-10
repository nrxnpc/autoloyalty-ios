import Foundation
import CoreData

/// Account domain entity with CoreData support
@objc(BalanceTransaction)
public class BalanceTransaction: Entity {
    @NSManaged public var typeRaw: String
    @NSManaged public var amount: Int
    @NSManaged public var transactionDescription: String
    
    public enum TransactionType: String, CaseIterable {
        case earned
        case spent
        case bonus
        case penalty
    }
    
    public var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .earned }
        set { typeRaw = newValue.rawValue }
    }
}

extension BalanceTransaction {
    static func createOrUpdate(from raw: RestEndpoint.PointTransaction, in context: NSManagedObjectContext) {
        let request = BalanceTransaction.byExternalID(raw.id)
        if let existing = try? context.fetch(request).first {
            existing.type = transactionType(from: raw.type)
            existing.amount = raw.amount
            existing.transactionDescription = raw.description
            if let date = ISO8601DateFormatter().date(from: raw.timestamp) {
                existing.createdAt = date
            }
        } else {
            create(from: raw, in: context)
        }
    }
    
    private static func create(from raw: RestEndpoint.PointTransaction, in context: NSManagedObjectContext) {
        let transaction = BalanceTransaction(context: context)
        transaction.sync.externalID = raw.id
        transaction.type = transactionType(from: raw.type)
        transaction.amount = raw.amount
        transaction.transactionDescription = raw.description
        transaction.createdAt = ISO8601DateFormatter().date(from: raw.timestamp) ?? .now
    }
    
    private static func transactionType(from type: RestEndpoint.TransactionType) -> TransactionType {
        switch type {
        case .earned: return .earned
        case .spent: return .spent
        case .bonus: return .bonus
        case .penalty: return .penalty
        }
    }
}
