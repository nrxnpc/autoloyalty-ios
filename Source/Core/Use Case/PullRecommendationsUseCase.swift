import Foundation
import ScopeGraph

/// Use case for pulling cars recommendations from API
public struct PullRecommendationsUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        let context = scope.coreDataContext
        let cars = try await scope.endpoint.getCars().cars
        
        try await context.perform {
            cars.forEach { raw in
                CarRecommendation.createOrUpdate(from: raw, in: context)
            }
            try context.save()
        }
    }
}
