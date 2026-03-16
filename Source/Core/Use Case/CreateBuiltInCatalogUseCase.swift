import Foundation
import ScopeGraph

public struct CreateBuiltInCatalogUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        let context = scope.createBackgroundContext()
        
        try await context.perform {
            let request =  Product.allProductsFetchRequest()
            let products = try context.fetch(request)
            guard products.isEmpty else {
                for product in products {
                    context.delete(product)
                }
                try context.save()
                return
            }
        }
        
        try await Product.fillInDemo(context: context)
    }
}
