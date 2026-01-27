import Foundation
import CoreData
import ScopeGraph

public struct PullCatalogUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        let context = scope.createBackgroundContext()
        let products = try await scope.endpoint.getProducts().products
        let receivedProductIds = Set(products.map { $0.id })
        
        try await context.perform {
            let productsToDelete = try context.fetch(Product.obsoleteProducts(excludingIDs: receivedProductIds))
            productsToDelete.forEach { context.delete($0) }
            
            products.forEach { raw in
                Product.createOrUpdate(from: raw, in: context)
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
