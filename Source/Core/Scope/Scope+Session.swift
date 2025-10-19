import Foundation
import ScopeGraph

// MARK: - Domain Session Models

public struct AppSessionInfo: Codable, Sendable, Equatable {
    public let sessionID: String
    public let accountID: String
    public let displayName: String
    public let email: String
    public let lastLoginDate: Date
    
    public var databaseIdentifier: String {
        sessionID
    }
    
    public init(sessionID: String, accountID: String, displayName: String, email: String, lastLoginDate: Date = Date()) {
        self.sessionID = sessionID
        self.accountID = accountID
        self.displayName = displayName
        self.email = email
        self.lastLoginDate = lastLoginDate
    }
    
    public static var guest: Self {
        .init(sessionID: "guest", accountID: "guest", displayName: "Guest", email: "guest@example.com")
    }
}

public struct AppSessionTokens: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    
    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

// MARK: - Type Aliases for Clean Architecture

/// Application-specific session component type
public typealias AppSessionComponent = SessionComponent<AppSessionInfo, AppSessionTokens>

/// Application-specific session actor type
public typealias AppSessionActor = SessionActor<AppSessionInfo, AppSessionTokens>

/// Application-specific session request type
public typealias AppSessionRequest = SessionRequest<AppSessionInfo, AppSessionTokens>

/// Application-specific session result type
public typealias AppSessionResult = SessionResult<AppSessionInfo, AppSessionTokens>

// MARK: - Session Factory

public struct SessionFactory {
    public static func createSessionComponent() -> AppSessionComponent {
        return StorageModule.session(
            sessionService: "com.nsp.sessions",
            tokenService: "com.nsp.tokens"
        )
    }
    
    public static func createGuestSession() -> AppSessionActor {
        return SessionActor(
            id: "guest",
            info: AppSessionInfo.guest,
            tokenService: "com.nsp.tokens",
            isGuest: true
        )
    }
}

public extension Scope {
    /// Update current session info
    @MainActor
    func updateSessionInfo(_ newInfo: AppSessionInfo) async throws {
        guard await !session.isGuest else { return }
        
        let sessionID = await session.id
        
        let request: AppSessionRequest = .updateInfo(sessionID: sessionID, info: newInfo)
        let result = try await sessionComponent.process(request)
        
        if case .session(let updatedSession) = result {
            await setActiveSession(updatedSession)
        }
        
        debugPrint("[DEBUG][Scope] update session info: \(newInfo)")
    }
    
    /// Switch to existing session
    @MainActor
    func switchSession(with sessionID: String) async throws {
        let request: AppSessionRequest = .restore(sessionID: sessionID)
        let result = try await sessionComponent.process(request)
        
        if case .session(let sessionActor) = result {
            try await switchToDataStorage(sessionActor.info.databaseIdentifier)
            let setActiveRequest: AppSessionRequest = .setActive(sessionID)
            _ = try await sessionComponent.process(setActiveRequest)
            await setActiveSession(sessionActor)
        }
    }
    
    /// Log out current user
    @MainActor
    func logOut() async throws {
        guard await !session.isGuest else {
            return
        }
        
        // Switch to guest session
        let guestSession = SessionFactory.createGuestSession()
        await setActiveSession(guestSession)
        try await switchToDataStorage("guest", inMemory: true)
    }
    
    /// Restore last active session
    func restoreLastActiveSession() async {
        do {
            let request: AppSessionRequest = .getActive
            let result = try await sessionComponent.process(request)
            
            if case .session(let sessionActor) = result {
                let tokens = await sessionActor.getTokens()
                if tokens != nil {
                    await setActiveSession(sessionActor)
                    try await switchToDataStorage(sessionActor.info.databaseIdentifier)
                    return
                }
            }
        } catch {}
        
        // Fallback to guest session
        let guestSession = SessionFactory.createGuestSession()
        await setActiveSession(guestSession)
    }
    
    /// Get all stored sessions
    func getStoredSessions() async -> [AppSessionInfo] {
        do {
            let request: AppSessionRequest = .list
            let result = try await sessionComponent.process(request)
            if case .sessions(let sessions) = result {
                return await withTaskGroup(of: AppSessionInfo?.self) { group in
                    for session in sessions {
                        group.addTask {
                            session.infoSync
                        }
                    }
                    
                    var infos: [AppSessionInfo] = []
                    for await info in group {
                        if let info = info {
                            infos.append(info)
                        }
                    }
                    return infos
                }
            }
        } catch {}
        return []
    }
    
    /// Remove stored session
    func removeStoredSession(_ sessionID: String) async throws {
        let request: AppSessionRequest = .remove(sessionID: sessionID)
        _ = try await sessionComponent.process(request)
    }
    
    /// Get current access token
    func getCurrentAccessToken() async -> String? {
        return await session.getTokens()?.accessToken
    }
    
    /// Refresh current tokens
    func refreshCurrentTokens() async throws {
        let refreshUseCase = RefreshTokenUseCase(scope: self)
        try await refreshUseCase.execute()
    }
    
    // MARK: - Private Methods
    
    /// Set active session and manage job scheduler lifecycle
    @MainActor
    internal func setActiveSession(_ newSession: AppSessionActor) async {
        // Stop job scheduler for current session
        if !session.isGuestSync {
            Task { await session.getJobScheduler()?.stopJobs() }
        }
        
        self.session = newSession
        await updateAuthenticator()
    }
    
    /// Switch to data storage for specific user
    internal func switchToDataStorage(_ userIdentifier: String, inMemory: Bool = false) async throws {
        let context = coreDataContext
        if context.hasChanges {
            try context.save()
        }
        dataPipeline.coreDataStack().switchUser(to: userIdentifier, inMemory: inMemory)
        debugPrint("[DEBUG][Scope] switched to database with identifier: \(CacheKey(userIdentifier).value)")
    }
    
    private func updateAuthenticator() async {
        if await session.isGuest {
            endpoint.setUnauthenticated()
        } else {
            endpoint.setAutoRefreshToken(
                tokenProvider: { [weak self] in await self?.getCurrentAccessToken() },
                refreshAction: { [weak self] in try await self?.refreshCurrentTokens() }
            )
        }
    }
}
