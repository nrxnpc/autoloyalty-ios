import Foundation
import ScopeGraph

/// Use case for user authentication
public struct LoginUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    /// Process login response and create session
    public func execute(email: String, password: String) async throws {
        let loginResponse = try await scope.endpoint.login(.init(email: email, password: password))
        // Create or reuse session
        let createSessionUseCase = CreateSessionUseCase(scope: scope)
        let sessionID = try await createSessionUseCase.execute(from: loginResponse)
        try await scope.switchSession(with: sessionID)
    }
}

public enum AuthenticationError: Error {
    case invalidEmail
    case invalidPassword
    case loginFailed
    case registrationFailed
    case passwordResetFailed
}
