import Foundation
import ScopeGraph

/// Use case for creating or restoring user session from login response
public struct CreateSessionUseCase: Sendable {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    // MARK: - Typedef
    
    enum CreateSessionUseCaseError: Error {
        case cantCreateSession
    }
    
    /// Create or restore session from login response
    @MainActor
    public func execute(from loginResponse: RestEndpoint.AuthResponse) async throws -> String {
        guard let user = loginResponse.user else {
            throw CreateSessionUseCaseError.cantCreateSession
        }
        let sessionID = user.id
        
        // Check if session exists
        let request: AppSessionRequest = .restore(sessionID: sessionID)
        let restoreResult = try await scope.sessionComponent.process(request)
        
        if case .session(let existingSession) = restoreResult {
            // Restore existing session
            return await existingSession.id
        }
        
        // Create new session
        try await scope.switchToDataStorage(sessionID)
        
        // Get or create account
        let accountID = try await getOrCreateAccount(from: user)
        
        let sessionInfo = AppSessionInfo(
            sessionID: sessionID,
            accountID: accountID,
            displayName: user.name,
            email: user.email
        )
        
        // TODO: fix loginResponse.tokens
        let tokens = AppSessionTokens(
            accessToken: loginResponse.token ?? "fix loginResponse.accessToken",
            refreshToken: "fix user.refreshToken"
        )
        
        let createRequest: AppSessionRequest = .create(
            sessionID: sessionID,
            info: sessionInfo,
            tokens: tokens
        )
        let createResult = try await scope.sessionComponent.process(createRequest)
        if case .session(let newSession) = createResult {
            return await newSession.id
        }
        
        throw CreateSessionUseCaseError.cantCreateSession
    }
    
    @MainActor
    private func getOrCreateAccount(from user: RestEndpoint.UserProfile) async throws -> String {
        // Try to find existing account by external ID
        let fetchRequest = Account.byExternalID(user.id)
        
        if let existingAccount = try scope.coreDataContext.fetch(fetchRequest).first {
            return existingAccount.id
        }
        
        let createUseCase = CreateAccountUseCase(
            context: scope.coreDataContext,
            id: UUID().uuidString,
            externalID: user.id,
            name: user.name,
            email: user.email
        )
        
        let newAccount = try createUseCase.execute()
        return newAccount.id
    }
}
