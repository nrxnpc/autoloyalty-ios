import Foundation
import ScopeGraph

public struct PullCatalogUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        let context = scope.createBackgroundContext()
        let products = try await scope.endpoint.getProducts().products
        try await context.perform {
            products.forEach { raw in
                Product.createOrUpdate(from: raw, in: context)
            }
            try context.save()
        }
    }
}
