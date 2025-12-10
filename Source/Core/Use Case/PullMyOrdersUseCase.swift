import Foundation
import ScopeGraph

/// Use case for pulling user orders from API
public struct PullMyOrdersUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        let context = scope.coreDataContext
        let orders = try await scope.endpoint.getUserOrders().orders
        try await context.perform {
            orders.forEach { raw in
                Order.createOrUpdate(from: raw, in: context)
            }
            try context.save()
        }
    }
}
