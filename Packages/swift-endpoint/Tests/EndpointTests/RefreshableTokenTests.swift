import XCTest
@testable import Endpoint

/// Tests demonstrating automatic token refresh functionality.
/// Shows thread-safe token refresh handling for concurrent requests.
final class RefreshableTokenTests: XCTestCase {
    
    private let baseURL = URL(string: "https://api.example.com/v1")!
    
    /// Demonstrates basic token refresh authenticator functionality.
    /// Shows that tokens can be refreshed when needed.
    func test_tokenRefreshAuthenticator_shouldRefreshTokens() async throws {
        // Given: A token storage that starts with expired token
        let tokenStorage = MockTokenStorage()
        await tokenStorage.setAccessToken("expired-token")
        
        var refreshCallCount = 0
        let authenticator = RefreshableTokenAuthenticator(
            tokenProvider: { await tokenStorage.getAccessToken() },
            refreshToken: {
                refreshCallCount += 1
                await tokenStorage.setAccessToken("fresh-token")
            }
        )
        
        // When: Handling authentication failure (simulating 401)
        try await authenticator.handleAuthenticationFailure()
        
        // Then: Token should be refreshed
        XCTAssertEqual(refreshCallCount, 1, "Should refresh token once")
        let finalToken = await tokenStorage.getAccessToken()
        XCTAssertEqual(finalToken, "fresh-token")
    }
    
    /// Shows handling of maximum retry attempts exceeded.
    /// Demonstrates behavior when multiple refresh attempts fail.
    func test_maxRetriesExceeded_shouldThrowMaxRetriesError() async {
        // Given: An authenticator with retry limit and failing refresh
        var attemptCount = 0
        let authenticator = RefreshableTokenAuthenticator(
            tokenProvider: { "expired-token" },
            refreshToken: {
                attemptCount += 1
                throw URLError(.timedOut)
            },
            maxRetries: 2
        )
        
        // When: All retry attempts fail
        do {
            try await authenticator.handleAuthenticationFailure()
            
            XCTFail("Should throw max retries exceeded error")
        } catch RefreshableTokenAuthenticator.RefreshError.refreshFailed {
            // Then: Should indicate refresh failed after retries
            XCTAssertEqual(attemptCount, 2, "Should attempt refresh max retry times")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - Test Helpers

actor MockTokenStorage {
    private var accessToken: String?
    
    func getAccessToken() -> String? {
        return accessToken
    }
    
    func setAccessToken(_ token: String) {
        accessToken = token
    }
}