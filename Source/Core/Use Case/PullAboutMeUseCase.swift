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
    public func execute() async throws {
        let currentSessionInfo = await scope.session.info
        let accountInfo = try await scope.endpoint.getCurrentUser().user

        try await upsertAccount(accountID: currentSessionInfo.accountID, from: accountInfo)
        try await validateSessionInfo(with: accountInfo)
    }
    
    /// Performs atomic account upsert operation within single transaction.
    /// Prevents race conditions by combining find-or-create and update operations.
    @MainActor
    private func upsertAccount(accountID: String, from accountInfo: RestEndpoint.UserProfile) async throws {
        let context = scope.createBackgroundContext()
        try await context.perform {
            if let account = try Account.byID(accountID).execute().first {
                // TODO: a name may be overriden by the user without backend sync
                // account.name = accountInfo.name
                
                account.email = accountInfo.email
                // TODO: Calc total account from history
                account.points = accountInfo.points
            } else {
                let account = try Account.create(id: accountID, externalID: accountInfo.id, in: context)
                account.name = accountInfo.name
                account.email = accountInfo.email
                account.points = accountInfo.points
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
    
    /// Updates session information if account data has changed.
    @MainActor
    private func validateSessionInfo(with accountInfo: RestEndpoint.UserProfile) async throws {
        let currentSessionInfo = await scope.session.info
        
        let needsUpdate = currentSessionInfo.displayName != accountInfo.name ||
        currentSessionInfo.email != accountInfo.email
        
        guard needsUpdate else { return }
        
        // TODO: a name may be overriden by the user without backend sync
        // displayName: accountInfo.name
        let updatedInfo = AppSessionInfo(
            sessionID: currentSessionInfo.sessionID,
            accountID: currentSessionInfo.accountID,
            displayName: currentSessionInfo.displayName,
            email: accountInfo.email
        )
        
        try await scope.updateSessionInfo(updatedInfo)
    }
}
