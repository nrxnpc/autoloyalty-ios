import Foundation
import ScopeGraph

/// Use case for refreshing authentication tokens
public struct RefreshTokenUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        let session = scope.session
        
        guard await !session.isGuest, let currentTokens = await session.getTokens() else {
            throw AuthenticationError.loginFailed
        }
        
        let response = try await scope.endpoint.refreshToken(.init(refreshToken: currentTokens.refreshToken))
        
        let newTokens = AppSessionTokens(
            accessToken: response.access_token,
            refreshToken: response.refresh_token
        )
        
        await session.setTokens(newTokens)
    }
}
