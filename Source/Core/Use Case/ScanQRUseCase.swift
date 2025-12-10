import Foundation
import ScopeGraph

public struct ScanQRUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute(value: String) async throws {
        let context = scope.coreDataContext
        let result = try await scope.endpoint.scanQRCode(.init(qrCode: value))
        
        try await context.perform {
            products.forEach { raw in
                Product.createOrUpdate(from: raw, in: context)
            }
            try context.save()
        }
    }
}
