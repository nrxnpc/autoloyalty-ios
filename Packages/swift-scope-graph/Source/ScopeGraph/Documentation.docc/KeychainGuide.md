# Keychain Guide

Secure data storage and management using the iOS/macOS Keychain.

## Overview

ScopeGraph's keychain integration provides secure, encrypted storage for sensitive data like passwords, tokens, and cryptographic keys.

## Keychain Fundamentals

### Basic Operations

```swift
import ScopeGraph

// Create a keychain for your app
let keychain = Keychain(service: "com.yourapp.credentials")

// Store sensitive data
try keychain.set("user_password", key: "password")
try keychain.set("api_token_12345", key: "api_token")

// Retrieve sensitive data
let password = try keychain.get("password")
let token = try keychain.get("api_token")
```

### Data Types

```swift
// Store strings
try keychain.set("secret_string", key: "string_key")

// Store binary data
let binaryData = Data([0x01, 0x02, 0x03])
try keychain.set(binaryData, key: "binary_key")

// Retrieve with type safety
let retrievedString = try keychain.getString("string_key")
let retrievedData = try keychain.getData("binary_key")
```

## Security Configuration

### Accessibility Levels

```swift
// Data accessible only when device is unlocked
let secureKeychain = keychain.accessibility(.whenUnlocked)

// Data accessible after first unlock (survives device restart)
let persistentKeychain = keychain.accessibility(.afterFirstUnlock)

// Data that never leaves this device (no iCloud sync)
let deviceOnlyKeychain = keychain.accessibility(.whenUnlockedThisDeviceOnly)
```

### Biometric Protection

```swift
// Require Touch ID or Face ID for access
let biometricKeychain = keychain.accessibility(
    .whenUnlockedThisDeviceOnly,
    authenticationPolicy: .biometryAny
)

try biometricKeychain.set("highly_sensitive_data", key: "biometric_key")
```

## Advanced Keychain Features

### Access Groups

```swift
// Share keychain items between apps in the same team
let sharedKeychain = Keychain(
    service: "com.yourteam.shared",
    accessGroup: "TEAMID.com.yourteam.shared"
)

try sharedKeychain.set("shared_secret", key: "team_key")
```

### Keychain Attributes

```swift
// Add metadata to keychain items
let labeledKeychain = keychain
    .label("User Authentication Token")
    .comment("OAuth token for API access")
    .synchronizable(false) // Don't sync to iCloud

try labeledKeychain.set("oauth_token", key: "auth_token")
```

### Querying Keychain Items

```swift
// Check if item exists without retrieving it
let exists = try keychain.contains("some_key")

// Get all keys for debugging (development only)
let allKeys = keychain.allKeys()

// Get item with attributes
let itemWithAttributes = try keychain.get("key") { attributes in
    return (attributes?.data, attributes?.label, attributes?.comment)
}
```

## Keychain Management Patterns

### Secure Token Manager

```swift
struct SecureTokenManager: ScopeGraphBuilder {
    private let keychain = Keychain(service: "com.app.tokens")
        .accessibility(.whenUnlockedThisDeviceOnly)
    
    func storeAccessToken(_ token: String, for userId: String) throws {
        let key = "access_token_\(userId)"
        try keychain.set(token, key: key)
    }
    
    func getAccessToken(for userId: String) throws -> String? {
        let key = "access_token_\(userId)"
        return try keychain.get(key)
    }
    
    func storeRefreshToken(_ token: String, for userId: String) throws {
        let key = "refresh_token_\(userId)"
        // Use biometric protection for refresh tokens
        let secureKeychain = keychain.accessibility(
            .whenUnlockedThisDeviceOnly,
            authenticationPolicy: .biometryAny
        )
        try secureKeychain.set(token, key: key)
    }
    
    func clearAllTokens(for userId: String) throws {
        try keychain.remove("access_token_\(userId)")
        try keychain.remove("refresh_token_\(userId)")
    }
}
```

### Credential Storage

```swift
struct CredentialManager: ScopeGraphBuilder {
    private let keychain = Keychain(service: "com.app.credentials")
    
    struct Credentials: Codable {
        let username: String
        let password: String
        let lastUpdated: Date
    }
    
    func storeCredentials(_ credentials: Credentials) throws {
        let data = try JSONEncoder().encode(credentials)
        try keychain.set(data, key: "user_credentials")
    }
    
    func getCredentials() throws -> Credentials? {
        guard let data = try keychain.getData("user_credentials") else {
            return nil
        }
        return try JSONDecoder().decode(Credentials.self, from: data)
    }
    
    func updatePassword(_ newPassword: String) throws {
        guard var credentials = try getCredentials() else {
            throw CredentialError.noExistingCredentials
        }
        
        credentials.password = newPassword
        credentials.lastUpdated = Date()
        try storeCredentials(credentials)
    }
}
```

### Encryption Key Management

```swift
struct EncryptionKeyManager: ScopeGraphBuilder {
    private let keychain = Keychain(service: "com.app.encryption")
        .accessibility(.whenPasscodeSetThisDeviceOnly)
    
    func generateAndStoreKey(for identifier: String) throws -> Data {
        // Generate a new encryption key
        var keyData = Data(count: 32) // 256-bit key
        let result = SecRandomCopyBytes(kSecRandomDefault, keyData.count, &keyData)
        
        guard result == errSecSuccess else {
            throw KeyGenerationError.randomGenerationFailed
        }
        
        // Store securely in keychain
        try keychain.set(keyData, key: "encryption_key_\(identifier)")
        return keyData
    }
    
    func getKey(for identifier: String) throws -> Data? {
        return try keychain.getData("encryption_key_\(identifier)")
    }
    
    func rotateKey(for identifier: String) throws -> Data {
        // Remove old key
        try keychain.remove("encryption_key_\(identifier)")
        
        // Generate and store new key
        return try generateAndStoreKey(for: identifier)
    }
}
```

## Error Handling

### Keychain Error Types

```swift
enum KeychainError: Error, LocalizedError {
    case itemNotFound
    case duplicateItem
    case authenticationFailed
    case userCanceled
    case unexpectedError(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "The requested keychain item was not found"
        case .duplicateItem:
            return "A keychain item with this key already exists"
        case .authenticationFailed:
            return "Authentication failed for keychain access"
        case .userCanceled:
            return "User canceled the keychain operation"
        case .unexpectedError(let status):
            return "Unexpected keychain error: \(status)"
        }
    }
}
```

### Safe Keychain Operations

```swift
struct SafeKeychainManager: ScopeGraphBuilder {
    private let keychain = Keychain(service: "com.app.safe")
    
    func safelyStore(_ value: String, forKey key: String) -> Bool {
        do {
            try keychain.set(value, key: key)
            return true
        } catch {
            print("Failed to store keychain item: \(error)")
            return false
        }
    }
    
    func safelyRetrieve(forKey key: String) -> String? {
        do {
            return try keychain.get(key)
        } catch {
            print("Failed to retrieve keychain item: \(error)")
            return nil
        }
    }
    
    func handleKeychainError(_ error: Error) {
        if let keychainError = error as? Status {
            switch keychainError {
            case .userCanceled:
                // User canceled biometric authentication
                showUserCanceledMessage()
            case .authFailed:
                // Authentication failed
                showAuthenticationFailedMessage()
            case .itemNotFound:
                // Item doesn't exist - this might be expected
                break
            default:
                // Other keychain errors
                showGenericErrorMessage()
            }
        }
    }
}
```

## Best Practices

### Key Naming Conventions

```swift
struct KeychainKeys {
    private static let prefix = "com.yourapp"
    
    static func userToken(_ userId: String) -> String {
        return "\(prefix).token.\(userId)"
    }
    
    static func encryptionKey(_ purpose: String) -> String {
        return "\(prefix).encryption.\(purpose)"
    }
    
    static func biometricData(_ type: String) -> String {
        return "\(prefix).biometric.\(type)"
    }
}
```

### Migration and Cleanup

```swift
struct KeychainMigrationManager: ScopeGraphBuilder {
    private let keychain = Keychain(service: "com.app.main")
    
    func migrateFromOldVersion() throws {
        // Migrate from old key format to new format
        if let oldToken = try keychain.get("old_token_key") {
            try keychain.set(oldToken, key: KeychainKeys.userToken("current_user"))
            try keychain.remove("old_token_key")
        }
    }
    
    func cleanupExpiredItems() throws {
        let allKeys = keychain.allKeys()
        
        for key in allKeys {
            if key.hasPrefix("temp_") {
                // Remove temporary items
                try keychain.remove(key)
            }
        }
    }
    
    func performSecurityAudit() throws {
        // Check for items that should have stronger security
        let allItems = keychain.allItems()
        
        for item in allItems {
            if let key = item["key"] as? String,
               key.contains("sensitive"),
               let accessibility = item["accessibility"] as? String,
               accessibility != Accessibility.whenUnlockedThisDeviceOnly.rawValue {
                
                print("Warning: Sensitive item '\(key)' has weak accessibility setting")
            }
        }
    }
}
```