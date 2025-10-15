import Foundation

/// Session management component providing secure session handling with actor-based concurrency
public struct SessionComponent<SessionInfo: Codable & Sendable, TokenInfo: Codable & Sendable>: DataComponent, Sendable {
    public typealias Input = SessionRequest<SessionInfo, TokenInfo>
    public typealias Output = SessionResult<SessionInfo, TokenInfo>
    
    private let storage: SecureStorageComponent
    private let tokenStorage: SecureStorageComponent
    private let tokenService: String
    
    public let identifier = "session_component"
    
    /// Initialize session component with secure storage
    /// - Parameters:
    ///   - sessionService: Service identifier for session storage
    ///   - tokenService: Service identifier for token storage
    public init(sessionService: String = "sessions", tokenService: String = "tokens") {
        self.storage = SecureStorageComponent(service: sessionService)
        self.tokenStorage = SecureStorageComponent(service: tokenService)
        self.tokenService = tokenService
    }
    
    public func process(_ request: SessionRequest<SessionInfo, TokenInfo>) async throws -> SessionResult<SessionInfo, TokenInfo> {
        switch request {
        case .create(let sessionID, let info, let tokens):
            return try await createSession(sessionID: sessionID, info: info, tokens: tokens)
        case .restore(let sessionID):
            return try await restoreSession(sessionID: sessionID)
        case .updateInfo(let sessionID, let info):
            return try await updateSessionInfo(sessionID: sessionID, info: info)
        case .remove(let sessionID):
            return try await removeSession(sessionID: sessionID)
        case .getActive:
            return await getActiveSession()
        case .setActive(let sessionID):
            return try await setActiveSession(sessionID: sessionID)
        case .list:
            return try await listSessions()
        }
    }
}

// MARK: - Request/Result Models

/// Session management requests
public enum SessionRequest<SessionInfo: Codable & Sendable, TokenInfo: Codable & Sendable>: Sendable {
    case create(sessionID: String, info: SessionInfo, tokens: TokenInfo?)
    case restore(sessionID: String)
    case updateInfo(sessionID: String, info: SessionInfo)
    case remove(sessionID: String)
    case getActive
    case setActive(String)
    case list
}

/// Session management results
public enum SessionResult<SessionInfo: Codable & Sendable, TokenInfo: Codable & Sendable>: Sendable {
    case session(SessionActor<SessionInfo, TokenInfo>)
    case sessions([SessionActor<SessionInfo, TokenInfo>])
    case success
    case notFound
}

// MARK: - Session Job Scheduling Protocol

/// Protocol for session job scheduling
public protocol SessionJobScheduling: Sendable {
    var sessionID: String { get }
    func startJobs() async
    func stopJobs() async
}

// MARK: - Session Actor

/// Thread-safe session actor managing authentication state and tokens
public actor SessionActor<SessionInfo: Codable & Sendable, TokenInfo: Codable & Sendable>: Sendable {
    public let id: String
    public let info: SessionInfo
    public let isGuest: Bool
    
    public nonisolated var isGuestSync: Bool {
        isGuest
    }
    
    public nonisolated var infoSync: SessionInfo {
        info
    }
    
    private let tokenStorage: SecureStorageComponent
    private var cachedTokens: TokenInfo?
    private var jobScheduler: (any SessionJobScheduling)?
    
    /// Initialize session actor
    /// - Parameters:
    ///   - id: Unique session identifier
    ///   - info: Session information
    ///   - tokenService: Service identifier for token storage
    ///   - isGuest: Whether this is a guest session
    public init(id: String, info: SessionInfo, tokenService: String = "tokens", isGuest: Bool = false) {
        self.id = id
        self.info = info
        self.isGuest = isGuest
        self.tokenStorage = SecureStorageComponent(service: tokenService)
    }
    
    /// Set job scheduler for this session
    public func setJobScheduler<T: SessionJobScheduling>(_ scheduler: T?) async {
        await jobScheduler?.stopJobs()
        self.jobScheduler = scheduler
        await scheduler?.startJobs()
    }
    
    /// Get current job scheduler
    public func getJobScheduler() async -> (any SessionJobScheduling)? {
        jobScheduler
    }
    
    /// Get stored tokens for this session
    /// - Returns: Token information if available
    public func getTokens() async -> TokenInfo? {
        if isGuest { return nil }
        
        if let cached = cachedTokens {
            return cached
        }
        
        let tokens = try? await tokenStorage.retrieve(forKey: "\(id)_tokens", as: TokenInfo.self)
        cachedTokens = tokens
        return tokens
    }
    
    /// Store or remove tokens for this session
    /// - Parameter tokens: Token information to store, nil to remove
    public func setTokens(_ tokens: TokenInfo?) async {
        if isGuest { return }
        
        cachedTokens = tokens
        
        if let tokens = tokens {
            try? await tokenStorage.store(tokens, forKey: "\(id)_tokens")
        } else {
            try? await tokenStorage.remove(forKey: "\(id)_tokens")
        }
    }
    
    /// Update session tokens
    /// - Parameter updater: Closure to update tokens
    public func updateTokens(_ updater: (TokenInfo?) async throws -> TokenInfo?) async rethrows {
        if isGuest { return }
        
        let currentTokens = await getTokens()
        let newTokens = try await updater(currentTokens)
        await setTokens(newTokens)
    }
}

// MARK: - Private Implementation

private extension SessionComponent {
    func createSession(sessionID: String, info: SessionInfo, tokens: TokenInfo?) async throws -> SessionResult<SessionInfo, TokenInfo> {
        let session = SessionActor<SessionInfo, TokenInfo>(id: sessionID, info: info, tokenService: tokenService)
        
        if let tokens = tokens {
            await session.setTokens(tokens)
        }
        
        try await storeSessionInfo(sessionID: sessionID, info: info)
        return .session(session)
    }
    
    func restoreSession(sessionID: String) async throws -> SessionResult<SessionInfo, TokenInfo> {
        guard let info = try await getSessionInfo(sessionID: sessionID) else {
            return .notFound
        }
        
        let session = SessionActor<SessionInfo, TokenInfo>(id: sessionID, info: info, tokenService: tokenService)
        return .session(session)
    }
    
    func updateSessionInfo(sessionID: String, info: SessionInfo) async throws -> SessionResult<SessionInfo, TokenInfo> {
        try await storeSessionInfo(sessionID: sessionID, info: info)
        let session = SessionActor<SessionInfo, TokenInfo>(id: sessionID, info: info, tokenService: tokenService)
        return .session(session)
    }
    
    func removeSession(sessionID: String) async throws -> SessionResult<SessionInfo, TokenInfo> {
        try await removeSessionInfo(sessionID: sessionID)
        try? await tokenStorage.remove(forKey: "\(sessionID)_tokens")
        
        // Clear active session if it matches
        if let activeSessionID = try? await storage.retrieve(forKey: "active_session", as: String.self),
           activeSessionID == sessionID {
            try? await storage.remove(forKey: "active_session")
        }
        
        return .success
    }
    
    func getActiveSession() async -> SessionResult<SessionInfo, TokenInfo> {
        guard let sessionID = try? await storage.retrieve(forKey: "active_session", as: String.self),
              let info = try? await getSessionInfo(sessionID: sessionID) else {
            return .notFound
        }
        
        let session = SessionActor<SessionInfo, TokenInfo>(id: sessionID, info: info, tokenService: tokenService)
        return .session(session)
    }
    
    func setActiveSession(sessionID: String) async throws -> SessionResult<SessionInfo, TokenInfo> {
        try await storage.store(sessionID, forKey: "active_session")
        return .success
    }
    
    func listSessions() async throws -> SessionResult<SessionInfo, TokenInfo> {
        let sessionMap = try await storage.retrieve(forKey: "sessions", as: [String: SessionInfo].self) ?? [:]
        
        let sessions = sessionMap.map { (sessionID, info) in
            SessionActor<SessionInfo, TokenInfo>(id: sessionID, info: info, tokenService: tokenService)
        }
        
        return .sessions(sessions)
    }
    
    func storeSessionInfo(sessionID: String, info: SessionInfo) async throws {
        var sessions = try await storage.retrieve(forKey: "sessions", as: [String: SessionInfo].self) ?? [:]
        sessions[sessionID] = info
        try await storage.store(sessions, forKey: "sessions")
    }
    
    func getSessionInfo(sessionID: String) async throws -> SessionInfo? {
        let sessions = try await storage.retrieve(forKey: "sessions", as: [String: SessionInfo].self) ?? [:]
        return sessions[sessionID]
    }
    
    func removeSessionInfo(sessionID: String) async throws {
        var sessions = try await storage.retrieve(forKey: "sessions", as: [String: SessionInfo].self) ?? [:]
        sessions.removeValue(forKey: sessionID)
        try await storage.store(sessions, forKey: "sessions")
    }
}

// MARK: - Equatable Support

extension SessionActor: Equatable where SessionInfo: Equatable {
    public static func == (lhs: SessionActor<SessionInfo, TokenInfo>, rhs: SessionActor<SessionInfo, TokenInfo>) -> Bool {
        lhs.id == rhs.id && lhs.info == rhs.info
    }
}

extension SessionActor: Hashable where SessionInfo: Hashable {
    public nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(info)
        hasher.combine(isGuest)
    }
}
