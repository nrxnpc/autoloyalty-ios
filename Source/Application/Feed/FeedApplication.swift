import Dependencies
import Foundation
import ScopeGraph

@MainActor
final class FeedApplication: ObservableObject {
    // MARK: - Dependencies
    
    @Dependency(\.scope) var scope
}

extension FeedApplication {
    
}
