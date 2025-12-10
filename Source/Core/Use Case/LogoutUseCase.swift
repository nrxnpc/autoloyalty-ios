import Foundation
import ScopeGraph

/// Use case for user authentication
public struct LogoutUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    /// Process logout and return to guest session
    public func execute() async throws {
        let currentSessionID = await scope.session.id
        
        // Remove stored session data
        if currentSessionID != "guest" {
            try await scope.removeStoredSession(currentSessionID)
        }
        
        // Switch to guest session
        try await scope.logOut()
    }
}
