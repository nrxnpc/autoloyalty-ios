import Foundation
import ScopeGraph

/// Synchronizes local account data with remote account information.
/// Performs atomic upsert operations to prevent duplicate account creation.
public struct PullAboutMeUseCase: Sendable {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    /// Executes account synchronization with atomic upsert operation.
    /// - Parameter accountInfo: Remote account data to synchronize
    @MainActor
    public func execute(with accountInfo: RestEndpoint.UserProfile) async throws {
        let currentSessionInfo = await scope.session.info
        
        try await upsertAccount(accountID: currentSessionInfo.accountID, from: accountInfo)
        try await validateSessionInfo(with: accountInfo)
    }
    
    /// Performs atomic account upsert operation within single transaction.
    /// Prevents race conditions by combining find-or-create and update operations.
    @MainActor
    private func upsertAccount(accountID: String, from accountInfo: RestEndpoint.UserProfile) async throws {
        try await scope.coreDataContext.perform {
            let account = try Account.byID(accountID).execute().first ?? Account.create(id: accountID, externalID: accountInfo.id, in: scope.coreDataContext)
            
            account.nickname = accountInfo.name
            account.email = accountInfo.email
            
            try scope.coreDataContext.save()
        }
    }
    
    /// Updates session information if account data has changed.
    @MainActor
    private func validateSessionInfo(with accountInfo: RestEndpoint.UserProfile) async throws {
        let currentSessionInfo = await scope.session.info
        
        let needsUpdate = currentSessionInfo.displayName != accountInfo.name ||
        currentSessionInfo.email != accountInfo.email
        
        guard needsUpdate else { return }
        
        let updatedInfo = AppSessionInfo(
            sessionID: currentSessionInfo.sessionID,
            accountID: currentSessionInfo.accountID,
            displayName: accountInfo.name,
            email: accountInfo.email
        )
        
        try await scope.updateSessionInfo(updatedInfo)
    }
}
