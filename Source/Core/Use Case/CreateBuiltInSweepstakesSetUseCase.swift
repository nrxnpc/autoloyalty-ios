import Foundation
import ScopeGraph

/// Use case for create welcome notificaiton
public struct CreateBuiltInSweepstakesSetUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        let context = scope.createBackgroundContext()
        let events = try context.fetch(Sweepstakes.allSweepstakesFetchRequest())
        guard events.isEmpty else {
            return
        }
        
        try await Sweepstakes.fillInDemo(context: context)
    }
}
