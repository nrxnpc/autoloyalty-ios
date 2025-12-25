import Foundation
import ScopeGraph

/// Use case for grab news, notifications, etc.
public struct PullUserTransactionsUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        let context = scope.createBackgroundContext()
        let transactions = try await scope.endpoint.getUserTransactions().transactions
        try await context.perform {
            transactions.forEach { raw in
                BalanceTransaction.createOrUpdate(from: raw, in: context)
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
        
        let total = transactions.reduce(0) { sum, transaction in
            switch transaction.type {
            case .bonus, .earned: return sum + transaction.amount
            case .penalty, .spent: return sum - transaction.amount
            }
        }
        
        let accountID = scope.currentSessionInfo.accountID
        try await context.perform {
            let request = Account.byID(accountID)
            guard let account = try context.fetch(request).first else {
                return
            }
            
            // TODO: for demo only
            if account.points < total {
                account.points = total
            }
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
