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
            try context.save()
        }
    }
}
