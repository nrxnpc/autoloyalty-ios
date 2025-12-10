import Foundation
import ScopeGraph

/// Use case for creating new order
public struct CreateOrderUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute(productId: String, quantity: Int = 1) async throws -> String {
        let request = RestEndpoint.OrderCreateRequest(productId: productId, quantity: quantity)
        let response = try await scope.endpoint.createOrder(request)
        
        guard response.success, let orderId = response.orderId else {
            throw NSError(domain: "CreateOrderError", code: 0, userInfo: [NSLocalizedDescriptionKey: response.error ?? "Unknown error"])
        }
        
        return orderId
    }
}
