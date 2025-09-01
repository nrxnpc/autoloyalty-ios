# Error Handling

Handle network errors, HTTP status codes, and authentication failures.

## Overview

Swift Endpoint provides comprehensive error handling with specific error types for different failure scenarios.

## Error Types

### EndpointError

The main error type for HTTP requests:

```swift
do {
    let data = try await endpoint.call()
} catch EndpointError.unexpectedStatusCode(let code) {
    // Handle HTTP errors (4xx, 5xx)
    print("HTTP error: \(code)")
} catch EndpointError.decodingFailed(let error) {
    // Handle JSON parsing errors
    print("Failed to decode response: \(error)")
} catch EndpointError.noData {
    // Handle empty responses when data expected
    print("No data received")
} catch EndpointError.requestFailed(let error) {
    // Handle network connectivity issues
    print("Network error: \(error)")
}
```

### Authentication Errors

Handle authentication-specific failures:

```swift
do {
    let data = try await endpoint.call()
} catch EndpointError.authenticationFailed(let error) {
    // Handle general auth errors
    print("Authentication failed: \(error)")
} catch BearerTokenAuthenticator.AuthError.tokenNotAvailable {
    // Handle missing tokens
    await redirectToLogin()
}
```

### Token Refresh Errors

Handle token refresh failures:

```swift
do {
    let data = try await endpoint.call()
} catch RefreshableTokenAuthenticator.RefreshError.refreshFailed(let error) {
    // Refresh token expired or invalid
    await clearTokensAndShowLogin()
} catch RefreshableTokenAuthenticator.RefreshError.maxRetriesExceeded {
    // Multiple refresh attempts failed
    await showRetryDialog()
}
```

## Best Practices

### Graceful Degradation

Handle optional service failures gracefully:

```swift
// Load critical data
let user = try await userAPI.getProfile()

// Handle optional avatar service failure
var avatarURL: String?
do {
    let avatar = try await userAPI.getAvatar()
    avatarURL = avatar.url
} catch EndpointError.unexpectedStatusCode(503) {
    // Service unavailable - continue without avatar
    avatarURL = nil
}
```

### Retry Logic

Implement retry logic for transient failures:

```swift
func fetchWithRetry<T: Codable>(
    _ endpoint: EndpointConfigurator,
    maxRetries: Int = 3
) async throws -> T {
    for attempt in 1...maxRetries {
        do {
            return try await endpoint.call()
        } catch EndpointError.requestFailed where attempt < maxRetries {
            // Wait before retry with exponential backoff
            let delay = UInt64(pow(2.0, Double(attempt)) * 1_000_000_000)
            try await Task.sleep(nanoseconds: delay)
        }
    }
    throw EndpointError.requestFailed(URLError(.networkConnectionLost))
}
```