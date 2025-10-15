import Foundation

/// Storage components factory
public struct StorageModule {
    /// Creates in-memory cache component for String keys and Data values
    public static func memory() -> CacheComponent<String, Data> {
        return CacheComponent<String, Data>()
    }
    
    /// Creates secure keychain storage component
    public static func secure(service: String) -> SecureStorageComponent {
        return SecureStorageComponent(service: service)
    }
    
    /// Creates persistent file storage component
    public static func persistent() -> PersistentStorageComponent {
        return PersistentStorageComponent()
    }
    
    /// Creates session management component with secure storage
    /// - Parameters:
    ///   - sessionService: Service identifier for session storage
    ///   - tokenService: Service identifier for token storage
    /// - Returns: Configured session component
    public static func session<SessionInfo: Codable & Sendable, TokenInfo: Codable & Sendable>(
        sessionService: String = "sessions",
        tokenService: String = "tokens"
    ) -> SessionComponent<SessionInfo, TokenInfo> {
        return SessionComponent<SessionInfo, TokenInfo>(
            sessionService: sessionService,
            tokenService: tokenService
        )
    }
}
