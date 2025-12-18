import Foundation
import ScopeGraph

/// Use case for user authentication
public struct DeleteAccountUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    enum DeleteAccountError: Error {
        case cantDeleteAccount
    }
    
    /// Process logout and return to guest session
    public func execute() async throws {
        let currentSessionID = await scope.session.id
        
        // Remove stored session data
        guard currentSessionID != "guest" else {
            return
        }
        
        let result = try await scope.endpoint.deleteUser(currentSessionID)
        if !result.success {
            throw DeleteAccountError.cantDeleteAccount
        }
        
        // Switch to guest session
        try await scope.logOut()
    }
}
