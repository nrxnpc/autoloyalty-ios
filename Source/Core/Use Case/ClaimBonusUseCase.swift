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

/// Use case for claiming bonus (creating order and waiting for sync)
public struct ClaimBonusUseCase {
    private let scope: Scope
    private let maxRetries: Int
    private let retryDelay: TimeInterval
    
    public enum ClaimBonusError: Error {
        case unableToPerformOperation
        case operationCompletedButResultDelayed
    }
    
    public init(scope: Scope, maxRetries: Int = 10, retryDelay: TimeInterval = 1.0) {
        self.scope = scope
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
    }
    
    public func execute(productId: String, quantity: Int = 1) async throws -> Order {
        // Step 1: Create order and get orderID
        let request = RestEndpoint.OrderCreateRequest(productId: productId, quantity: quantity)
        let response = try await scope.endpoint.createOrder(request)
        
        guard response.success, let orderId = response.orderId else {
            throw ClaimBonusError.unableToPerformOperation
        }
        
        // Step 2: Poll until order appears in local database
        let pullOrdersUseCase = PullMyOrdersUseCase(scope: scope)
        
        for attempt in 0..<maxRetries {
            // Pull orders from API
            try await pullOrdersUseCase.execute()
            
            // Check if order exists in local database
            let context = scope.createBackgroundContext()
            let order = try await context.perform {
                let request = Order.byExternalID(orderId)
                return try context.fetch(request).first
            }
            
            if let order = order {
                try await PullAboutMeUseCase(scope: scope).execute()
                return order
            }
            
            // Wait before next retry
            if attempt < maxRetries - 1 {
                try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
            }
        }
        
        throw ClaimBonusError.operationCompletedButResultDelayed
    }
}

extension ClaimBonusUseCase {
    /// Mock execute - creates fake order with success
    public func mockExecuteSuccess(
        productId: String,
        quantity: Int = 1,
        orderStatus: Order.OrderStatus = .pending,
        delay: TimeInterval = 0.5
    ) async throws -> Order {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        // Create fake order in local database
        let context = scope.createBackgroundContext()
        return try await context.perform {
            // Fetch the product
            let productRequest = Product.byExternalID(productId)
            guard let product = try context.fetch(productRequest).first else {
                throw ClaimBonusError.unableToPerformOperation
            }
            
            // Create fake order
            let order = Order(context: context)
            order.sync.externalID = UUID().uuidString
            order.status = orderStatus
            order.quantity = quantity
            order.totalPoints = product.pointsCost * quantity
            order.productName = product.name
            order.productCategory = product.category
            order.product = product
            order.createdAt = Date()
            
            try context.save()
            return order
        }
    }
    
    /// Mock execute - simulates operation failure
    public func mockExecuteFailure(
        errorMessage: String = "Unable to create order",
        delay: TimeInterval = 0.5
    ) async throws -> Order {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        // Throw error
        throw ClaimBonusError.unableToPerformOperation
    }
    
    /// Mock execute - simulates delayed result
    public func mockExecuteDelayed(
        delay: TimeInterval = 0.5
    ) async throws -> Order {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        // Throw delayed error
        throw ClaimBonusError.operationCompletedButResultDelayed
    }
    
    /// Mock execute - creates order with specific status
    public func mockExecuteWithStatus(
        productId: String,
        quantity: Int = 1,
        status: Order.OrderStatus,
        delay: TimeInterval = 0.5
    ) async throws -> Order {
        try await mockExecuteSuccess(
            productId: productId,
            quantity: quantity,
            orderStatus: status,
            delay: delay
        )
    }
}
