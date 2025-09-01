import XCTest
@testable import Endpoint

/// Tests demonstrating core authentication strategies and security patterns.
/// Focuses on basic auth functionality without network calls.
final class AuthenticationTests: XCTestCase {
    
    private let baseURL = URL(string: "https://api.example.com/v1")!
    
    // MARK: - Bearer Token Authentication
    
    /// Demonstrates the most common authentication pattern: Bearer tokens.
    /// Shows how to securely attach JWT or API tokens to requests.
    func test_bearerTokenAuthentication_shouldAddAuthorizationHeader() async throws {
        // Given: A valid authentication token
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
        let authenticator = BearerTokenAuthenticator { token }
        
        // When: Authenticating a request
        var request = URLRequest(url: baseURL)
        try await authenticator.authenticate(request: &request)
        
        // Then: The Authorization header should be properly set
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(token)")
    }
    
    /// Demonstrates proper error handling when tokens are unavailable.
    /// Critical for preventing requests to protected endpoints without auth.
    func test_missingToken_shouldThrowAuthenticationError() async {
        // Given: An authenticator that cannot provide a token
        let authenticator = BearerTokenAuthenticator { nil }
        
        // When: Attempting to authenticate without a token
        do {
            var request = URLRequest(url: baseURL)
            try await authenticator.authenticate(request: &request)
            
            XCTFail("Should throw authentication error when token is unavailable")
        } catch BearerTokenAuthenticator.AuthError.tokenNotAvailable {
            // Then: The appropriate error should be thrown
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Unauthenticated Sessions
    
    /// Shows the fail-fast pattern for unauthenticated sessions.
    /// Prevents accidental requests to protected endpoints when logged out.
    func test_unauthenticatedSession_shouldFailFastForProtectedEndpoints() async {
        // Given: An explicitly unauthenticated session
        let unauthenticatedSession = UnauthenticatedAuthenticator()
        
        // When: Attempting to access a protected endpoint
        do {
            var request = URLRequest(url: baseURL)
            try await unauthenticatedSession.authenticate(request: &request)
            
            XCTFail("Should prevent access to protected endpoints when unauthenticated")
        } catch UnauthenticatedAuthenticator.Error.accessAttemptedWhenUnauthenticated {
            // Then: Access should be denied before making network request
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Custom Authentication Strategies
    
    /// Demonstrates implementing custom authentication methods.
    /// Shows how to extend the library for API keys, signatures, etc.
    func test_customAuthentication_shouldSupportCustomAuthStrategies() async throws {
        // Given: A custom API key authentication strategy
        let apiKeyAuth = APIKeyAuthenticator(apiKey: "sk_test_123456789")
        
        // When: Using custom authentication
        var request = URLRequest(url: baseURL)
        try await apiKeyAuth.authenticate(request: &request)
        
        // Then: Custom headers should be applied
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-API-Key"), "sk_test_123456789")
    }
}

// MARK: - Test Authenticators

/// Example custom authenticator for API key authentication
struct APIKeyAuthenticator: Authenticator {
    let apiKey: String
    
    func authenticate(request: inout URLRequest) async throws {
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
    }
}