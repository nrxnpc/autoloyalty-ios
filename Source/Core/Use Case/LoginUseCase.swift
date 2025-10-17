import Foundation
import ScopeGraph

/// Use case for user authentication
public struct LoginUseCase: Sendable {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    /// Process login response and create session
    @MainActor
    public func execute(_ loginResponse: RestEndpoint.AuthResponse) async throws {
        // Create session first
        let createSessionUseCase = CreateSessionUseCase(scope: scope)
        let sessionID = try await createSessionUseCase.execute(from: loginResponse)
        try await scope.switchSession(with: sessionID)
        
        // Then sync account data
        guard let profile = loginResponse.user else {
            return
        }
        try await PullAboutMeUseCase(scope: scope).execute(with: profile)
    }
}

public enum AuthenticationError: Error {
    case invalidEmail
    case invalidPassword
    case loginFailed
    case registrationFailed
    case passwordResetFailed
}
