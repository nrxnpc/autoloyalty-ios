# Swift Endpoint

[![Swift](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS%20|%20visionOS-blue.svg)](https://swift.org)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)

A type-safe DSL for building REST API clients with fluent interface design and automatic token refresh.

## Features

- 🔗 **Fluent Interface** - Chain methods for readable request construction
- 🛡️ **Type Safety** - Compile-time safety with Swift's type system
- 🔄 **Auto Token Refresh** - Thread-safe automatic token refresh on 401 errors
- ⚡ **Async/Await** - Modern Swift concurrency support
- 🔐 **Authentication** - Built-in Bearer token and custom auth strategies
- 📊 **Network Logging** - Integrated Pulse logging for debugging
- ⚠️ **Error Handling** - Comprehensive error types with detailed descriptions

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/swift-endpoint.git", from: "1.0.0")
]
```

Or add via Xcode: **File → Add Package Dependencies**

## Quick Start

### Basic Usage

```swift
import Endpoint

// Simple GET request
let users: [User] = try await Endpoint(baseURL: apiURL)
    .get("users")
    .call()

// POST with JSON body
try await Endpoint(baseURL: apiURL)
    .post("users")
    .body(newUser)
    .call()

// Query parameters
let tasks: [Task] = try await Endpoint(baseURL: apiURL)
    .get("tasks")
    .parameter(key: "status", value: "active")
    .parameter(key: "limit", value: "10")
    .call()
```

### Authentication

```swift
// Bearer token authentication
let auth = BearerTokenAuthenticator { 
    await tokenStorage.getToken() 
}

let profile: UserProfile = try await Endpoint(baseURL: apiURL)
    .get("profile")
    .authenticate(with: auth)
    .call()
```

### Automatic Token Refresh

```swift
let refreshableAuth = RefreshableTokenAuthenticator(
    tokenProvider: { await tokenStorage.getAccessToken() },
    refreshToken: {
        // Called automatically on 401 errors
        let response = try await authAPI.refreshTokens()
        await tokenStorage.save(response.accessToken, response.refreshToken)
    }
)

// Automatically handles token refresh - no manual 401 handling needed
let data = try await Endpoint(baseURL: apiURL)
    .get("protected-resource")
    .authenticate(with: refreshableAuth)
    .call()
```

## Advanced Usage

### Custom Authentication

```swift
struct APIKeyAuthenticator: Authenticator {
    let apiKey: String
    
    func authenticate(request: inout URLRequest) async throws {
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
    }
}
```

### Error Handling

```swift
do {
    let data = try await endpoint.call()
} catch EndpointError.unexpectedStatusCode(let code) {
    // Handle HTTP errors
} catch RefreshableTokenAuthenticator.RefreshError.refreshFailed {
    // Handle token refresh failures
    await clearTokensAndShowLogin()
} catch EndpointError.decodingFailed(let error) {
    // Handle JSON parsing errors
}
```

### API Organization

```swift
struct UserAPI: EndpointBuilder {
    let baseURL: URL
    let auth: Authenticator
    
    func getUsers() async throws -> [User] {
        try await Endpoint(baseURL: baseURL)
            .get("users")
            .authenticate(with: auth)
            .call()
    }
    
    func createUser(_ user: CreateUserRequest) async throws -> User {
        try await Endpoint(baseURL: baseURL)
            .post("users")
            .body(user)
            .authenticate(with: auth)
            .call()
    }
}
```

## UI Components

For debugging and development, import the UI components:

```swift
import EndpointUI

// Network debugging console
PulseConsoleView()
```

## Documentation

- [Getting Started](Sources/Endpoint/Documentation.docc/GettingStarted.md)
- [Authentication Guide](Sources/Endpoint/Documentation.docc/Authentication.md)
- [Error Handling](Sources/Endpoint/Documentation.docc/ErrorHandling.md)
- [API Reference](https://your-org.github.io/swift-endpoint/documentation/endpoint/)

## Requirements

- iOS 17.0+ / macOS 15.0+ / tvOS 15.0+ / watchOS 9.0+ / visionOS 1.0+
- Swift 6.0+
- Xcode 16.0+

## License

MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details.