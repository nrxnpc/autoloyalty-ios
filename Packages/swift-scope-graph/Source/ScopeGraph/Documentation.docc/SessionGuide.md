# Session Management Guide

Learn how to implement secure session management with actor-based concurrency using ScopeGraph's SessionComponent.

## Overview

The SessionComponent provides a secure, thread-safe way to manage user sessions and authentication tokens. It uses actor-based concurrency to ensure data integrity and supports generic session and token types.

## Basic Usage

### Creating a Session Component

```swift
import ScopeGraph

struct UserSession: Codable, Sendable {
    let userID: String
    let email: String
    let displayName: String
}

struct AuthTokens: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
}

let sessionComponent = StorageModule.session<UserSession, AuthTokens>()
```

### Creating a New Session

```swift
let userSession = UserSession(
    userID: "user123",
    email: "user@example.com",
    displayName: "John Doe"
)

let tokens = AuthTokens(
    accessToken: "access_token_here",
    refreshToken: "refresh_token_here"
)

let result = try await sessionComponent.process(.create(
    sessionID: "session_123",
    info: userSession,
    tokens: tokens
))

if case .session(let sessionActor) = result {
    // Session created successfully
    print("Session created for user: \(sessionActor.info.displayName)")
}
```

### Restoring an Existing Session

```swift
let result = try await sessionComponent.process(.restore(sessionID: "session_123"))

if case .session(let sessionActor) = result {
    // Session restored
    let tokens = await sessionActor.getTokens()
    print("Restored session with tokens: \(tokens != nil)")
} else if case .notFound = result {
    // Session not found
    print("Session not found")
}
```

## Active Session Management

### Setting Active Session

```swift
// Set a session as active
_ = try await sessionComponent.process(.setActive("session_123"))

// Get the current active session
let activeResult = try await sessionComponent.process(.getActive)

if case .session(let activeSession) = activeResult {
    print("Active user: \(activeSession.info.displayName)")
}
```

## Token Management

The SessionActor provides thread-safe token management:

### Basic Token Operations

```swift
// Get current tokens
let tokens = await sessionActor.getTokens()

// Update tokens
let newTokens = AuthTokens(
    accessToken: "new_access_token",
    refreshToken: "new_refresh_token"
)
await sessionActor.setTokens(newTokens)

// Remove tokens (logout)
await sessionActor.setTokens(nil)
```

### Advanced Token Updates

```swift
// Update tokens with a closure
await sessionActor.updateTokens { currentTokens in
    guard let current = currentTokens else { return nil }
    
    // Refresh logic here
    return AuthTokens(
        accessToken: "refreshed_access_token",
        refreshToken: current.refreshToken
    )
}
```

## Session Lifecycle

### Complete Session Management Flow

```swift
class SessionManager {
    private let sessionComponent = StorageModule.session<UserSession, AuthTokens>()
    
    func login(email: String, password: String) async throws -> SessionActor<UserSession, AuthTokens> {
        // Authenticate with server
        let loginResponse = try await authenticate(email: email, password: password)
        
        // Create session
        let userSession = UserSession(
            userID: loginResponse.userID,
            email: email,
            displayName: loginResponse.displayName
        )
        
        let tokens = AuthTokens(
            accessToken: loginResponse.accessToken,
            refreshToken: loginResponse.refreshToken
        )
        
        let result = try await sessionComponent.process(.create(
            sessionID: "user_\(loginResponse.userID)",
            info: userSession,
            tokens: tokens
        ))
        
        // Set as active session
        _ = try await sessionComponent.process(.setActive("user_\(loginResponse.userID)"))
        
        if case .session(let sessionActor) = result {
            return sessionActor
        } else {
            throw SessionError.creationFailed
        }
    }
    
    func logout() async throws {
        let activeResult = try await sessionComponent.process(.getActive)
        
        if case .session(let activeSession) = activeResult {
            // Clear tokens
            await activeSession.setTokens(nil)
            
            // Remove session
            _ = try await sessionComponent.process(.remove(sessionID: activeSession.id))
        }
    }
    
    func restoreSession() async -> SessionActor<UserSession, AuthTokens>? {
        let activeResult = try? await sessionComponent.process(.getActive)
        
        if case .session(let sessionActor) = activeResult {
            // Verify tokens are still valid
            let tokens = await sessionActor.getTokens()
            return tokens != nil ? sessionActor : nil
        }
        
        return nil
    }
}
```

## Security Considerations

### Secure Storage

The SessionComponent automatically uses secure keychain storage for both session information and tokens:

- Session data is encrypted at rest
- Tokens are stored separately with additional security
- Automatic cleanup on session removal

### Thread Safety

All session operations are thread-safe through actor isolation:

```swift
// Safe concurrent access
Task {
    let tokens1 = await sessionActor.getTokens()
}

Task {
    await sessionActor.setTokens(newTokens)
}
```

## Error Handling

### Common Error Patterns

```swift
do {
    let result = try await sessionComponent.process(.restore(sessionID: sessionID))
    
    switch result {
    case .session(let sessionActor):
        // Success
        break
    case .notFound:
        // Handle missing session
        break
    default:
        // Handle unexpected result
        break
    }
} catch {
    // Handle storage errors
    print("Session error: \(error)")
}
```

## Best Practices

### 1. Use Meaningful Session IDs

```swift
// Good: Descriptive and unique
let sessionID = "user_\(userID)_\(timestamp)"

// Avoid: Generic or predictable IDs
let sessionID = "session1"
```

### 2. Implement Token Refresh

```swift
extension SessionActor {
    func refreshTokensIfNeeded() async throws {
        await updateTokens { currentTokens in
            guard let tokens = currentTokens,
                  isTokenExpired(tokens.accessToken) else {
                return currentTokens
            }
            
            // Refresh token logic
            return try await refreshTokens(tokens.refreshToken)
        }
    }
}
```

### 3. Handle Session Cleanup

```swift
func cleanupExpiredSessions() async throws {
    let result = try await sessionComponent.process(.list)
    
    if case .sessions(let sessions) = result {
        for session in sessions {
            let tokens = await session.getTokens()
            if let tokens = tokens, isTokenExpired(tokens.refreshToken) {
                _ = try await sessionComponent.process(.remove(sessionID: session.id))
            }
        }
    }
}
```

## Integration with DataPipeline

The SessionComponent integrates seamlessly with ScopeGraph's DataPipeline:

```swift
let pipeline = DataPipeline()
    .add(sessionComponent)
    .add(networkComponent)
    .add(cacheComponent)

// Use in pipeline
let sessionResult = try await pipeline.process(SessionRequest.getActive)
```