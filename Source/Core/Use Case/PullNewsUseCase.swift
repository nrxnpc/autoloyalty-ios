import Foundation
import ScopeGraph

public struct PullNewsUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        let context = scope.coreDataContext
        let news = try await scope.endpoint.getNews().news
        try await context.perform {
            news.forEach { raw in
                InboxMessage.createOrUpdate(from: raw, in: context)
            }
            try context.save()
        }
    }
}
