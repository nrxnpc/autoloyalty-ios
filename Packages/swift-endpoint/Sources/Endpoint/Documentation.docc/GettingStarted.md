# Getting Started

Learn how to build HTTP requests using Swift Endpoint's fluent interface.

## Quick Start

### Basic GET Request

```swift
import Endpoint

let users: [User] = try await Endpoint(baseURL: apiURL)
    .get("users")
    .call()
```

### POST with Body

```swift
let newUser = CreateUserRequest(name: "John", email: "john@example.com")

try await Endpoint(baseURL: apiURL)
    .post("users")
    .body(newUser)
    .call()
```

### Authenticated Requests

```swift
let auth = BearerTokenAuthenticator { 
    await tokenStorage.getToken() 
}

let profile: UserProfile = try await Endpoint(baseURL: apiURL)
    .get("profile")
    .authenticate(with: auth)
    .call()
```

## Advanced Features

### Query Parameters

```swift
let users: [User] = try await Endpoint(baseURL: apiURL)
    .get("users")
    .parameter(key: "status", value: "active")
    .parameter(key: "limit", value: "10")
    .call()
```

### Automatic Token Refresh

```swift
let refreshableAuth = RefreshableTokenAuthenticator(
    tokenProvider: { await tokenStorage.getAccessToken() },
    refreshToken: {
        let newTokens = try await authAPI.refreshTokens()
        await tokenStorage.save(newTokens)
    }
)

// Automatically handles 401 errors and token refresh
let data = try await Endpoint(baseURL: apiURL)
    .get("protected-resource")
    .authenticate(with: refreshableAuth)
    .call()
```