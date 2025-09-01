# Authentication

Secure your API requests with various authentication strategies.

## Overview

Swift Endpoint provides flexible authentication mechanisms that integrate seamlessly with the request building process.

## Authentication Types

### Bearer Token Authentication

The most common authentication pattern for modern APIs:

```swift
let auth = BearerTokenAuthenticator { 
    await keychain.getToken() 
}

let data = try await Endpoint(baseURL: apiURL)
    .get("protected")
    .authenticate(with: auth)
    .call()
```

### Automatic Token Refresh

Handle token expiration automatically:

```swift
let refreshableAuth = RefreshableTokenAuthenticator(
    tokenProvider: { await tokenStorage.getAccessToken() },
    refreshToken: {
        // Called automatically on 401 errors
        let response = try await authAPI.refresh()
        await tokenStorage.save(response.accessToken, response.refreshToken)
    }
)
```

### Custom Authentication

Implement custom authentication strategies:

```swift
struct APIKeyAuthenticator: Authenticator {
    let apiKey: String
    
    func authenticate(request: inout URLRequest) async throws {
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
    }
}
```

## Error Handling

Handle authentication errors gracefully:

```swift
do {
    let data = try await endpoint.call()
} catch RefreshableTokenAuthenticator.RefreshError.tokenNotAvailable {
    // Redirect to login
    await showLoginScreen()
} catch RefreshableTokenAuthenticator.RefreshError.refreshFailed {
    // Clear tokens and force re-authentication
    await clearTokensAndShowLogin()
}
```

## Thread Safety

All authenticators are designed to be thread-safe and handle concurrent requests properly. The `RefreshableTokenAuthenticator` ensures only one token refresh operation occurs even when multiple requests fail simultaneously.