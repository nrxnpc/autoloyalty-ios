import Dependencies
import Foundation
import ScopeGraph

@MainActor
final class RewardDetails: ObservableObject {
    @Dependency(\.scope) var scope
    @Published var product: FetchedObject<Product>
    
    init(productID: String) {
        _product = .init(initialValue: .init(Product.by(id: productID)))
        product.startObserving(context: scope.coreDataContext)
    }
}
