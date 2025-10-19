# Getting Started

Learn how to use ScopeGraph for efficient data management in your Swift applications.

## Quick Start

### Basic Cache Usage

```swift
import ScopeGraph

// Create a cache for user profiles
let userCache = Cache<String, UserProfile>()

// Store user data
let user = UserProfile(id: "123", name: "John", email: "john@example.com")
userCache.insert(user, forKey: user.id)

// Retrieve user data
if let cachedUser = userCache.value(forKey: "123") {
    print("Found user: \(cachedUser.name)")
}
```

### Secure Keychain Storage

```swift
import ScopeGraph

// Create a keychain for your app
let keychain = Keychain(service: "com.yourapp.tokens")

// Store sensitive data
try keychain.set("secret_api_token", key: "api_token")

// Retrieve sensitive data
if let token = try keychain.get("api_token") {
    print("Retrieved token securely")
}
```

### Data Manager Pattern

```swift
import ScopeGraph

struct UserDataManager: ScopeGraphBuilder {
    private let cache = Cache<String, UserProfile>()
    private let keychain = Keychain(service: "com.yourapp.users")
    
    func cacheUser(_ user: UserProfile) {
        cache.insert(user, forKey: user.id)
    }
    
    func storeUserToken(_ token: String, for userId: String) throws {
        try keychain.set(token, key: "token_\(userId)")
    }
    
    func getUserToken(for userId: String) throws -> String? {
        return try keychain.get("token_\(userId)")
    }
}
```

## Advanced Features

### Cache Configuration

```swift
// Configure cache with custom settings
let cache = Cache<String, Data>(
    dateProvider: Date.init,
    entryLifetime: 3600, // 1 hour
    maximumEntryCount: 100
)

// Use subscript syntax for convenience
cache["key"] = data
let retrievedData = cache["key"]
```

### Keychain Security Levels

```swift
// Configure keychain with specific accessibility
let secureKeychain = keychain
    .accessibility(.whenUnlockedThisDeviceOnly)
    .label("User Credentials")
    .comment("Stored securely for offline access")

try secureKeychain.set("sensitive_data", key: "secure_key")
```

### Persistent Storage

```swift
// Save cache to disk for persistence
try cache.saveToDisk(withName: "user_cache")

// Load cache from disk
let restoredCache = try Cache<String, UserProfile>(from: decoder)
```