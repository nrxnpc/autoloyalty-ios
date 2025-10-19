import Foundation

/// Thread-safe authenticator that automatically refreshes tokens when they expire.
/// Ensures only one refresh request is made even when multiple concurrent requests fail.
public actor RefreshableTokenAuthenticator: Authenticator {
    
    public enum RefreshError: Error, LocalizedError {
        case tokenNotAvailable
        case refreshFailed(Error)
        case maxRetriesExceeded
        
        public var errorDescription: String? {
            switch self {
            case .tokenNotAvailable: return "No token available for authentication"
            case .refreshFailed(let error): return "Token refresh failed: \(error.localizedDescription)"
            case .maxRetriesExceeded: return "Maximum token refresh retries exceeded"
            }
        }
    }
    
    private let tokenProvider: () async -> String?
    private let refreshToken: () async throws -> Void
    private let maxRetries: Int
    
    private var isRefreshing = false
    private var refreshTask: Task<Void, Error>?
    
    /// Creates a refreshable token authenticator.
    /// - Parameters:
    ///   - tokenProvider: Async function that returns current token
    ///   - refreshToken: Async function that refreshes the token
    ///   - maxRetries: Maximum number of refresh attempts (default: 1)
    public init(
        tokenProvider: @escaping () async -> String?,
        refreshToken: @escaping () async throws -> Void,
        maxRetries: Int = 1
    ) {
        self.tokenProvider = tokenProvider
        self.refreshToken = refreshToken
        self.maxRetries = maxRetries
    }
    
    public func authenticate(request: inout URLRequest) async throws {
        guard let token = await tokenProvider() else {
            throw RefreshError.tokenNotAvailable
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    /// Attempts to refresh the token if authentication fails.
    /// Thread-safe: multiple concurrent calls will wait for single refresh operation.
    public func handleAuthenticationFailure() async throws {
        // If already refreshing, wait for existing refresh to complete
        if let existingTask = refreshTask {
            try await existingTask.value
            return
        }
        
        // Start new refresh task
        let task = Task {
            defer { 
                refreshTask = nil
                isRefreshing = false
            }
            
            isRefreshing = true
            
            for attempt in 1...maxRetries {
                do {
                    try await refreshToken()
                    return
                } catch {
                    if attempt == maxRetries {
                        throw RefreshError.refreshFailed(error)
                    }
                    // Brief delay before retry
                    try await Task.sleep(nanoseconds: 100_000_000) // 100ms
                }
            }
            
            throw RefreshError.maxRetriesExceeded
        }
        
        refreshTask = task
        try await task.value
    }
}