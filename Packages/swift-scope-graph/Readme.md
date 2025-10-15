# ScopeGraph

[![Swift](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS%20|%20visionOS-blue.svg)](https://swift.org)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)

Modular data management framework built like "Lego Technics" - assemble exactly the components your app needs.

## 🧩 Lego Technics Philosophy

ScopeGraph provides independent, reusable components for data management. Like Lego Technics pieces, each component solves a specific problem and easily combines with others.

## ⚡ Quick Start

### Ready-Made Kits
```swift
import ScopeGraph

// User data management
let userManager = ScopeGraphKits.userDataKit()
try await userManager.store(user, forKey: "current_user")

// Media content management
let mediaManager = ScopeGraphKits.mediaKit()
try await mediaManager.store(imageData, forKey: "avatar_123")

// API response caching
let apiCache = ScopeGraphKits.apiCacheKit()
try await apiCache.store(response, forKey: "users_endpoint")
```

### Custom Assembly
```swift
// Assemble needed components
let customPipeline = ScopeGraph()
    .register(StorageModule.memory<String, Data>())
    .register(ProcessingModule.compression())
    .register(OptimizationModule.batteryAware())
    .build()

// Use assembled pipeline
try await customPipeline.store(data, forKey: "compressed_data")
let retrieved = try await customPipeline.retrieve(forKey: "compressed_data", as: Data.self)
```

### Pipeline Builder
```swift
let pipeline = DataPipelineBuilder()
    .add(StorageModule.secure(service: "com.app.tokens"))
    .add(ProcessingModule.encryption(key: encryptionKey))
    .add(OptimizationModule.batteryAware())
    .build()
```

## 🏗️ Component Architecture

### 📦 Storage Module
```swift
// In-memory caching
StorageModule.memory<String, UserProfile>()

// Secure keychain storage
StorageModule.secure(service: "com.app.credentials")

// Persistent disk storage
StorageModule.persistent()
```

### ⚙️ Processing Module
```swift
// Data compression
ProcessingModule.compression()

// Object serialization
ProcessingModule.serialization<User>()

// Data encryption
ProcessingModule.encryption(key: secretKey)
```

### 🚀 Optimization Module
```swift
// Battery-aware optimization
OptimizationModule.batteryAware()

// Memory management
OptimizationModule.memoryEfficient()

// Network optimization
OptimizationModule.networkAware()
```

## 📋 Ready-Made Kits

### 👤 User Data Kit
Optimized for user data with secure storage:
```swift
let userKit = ScopeGraphKits.userDataKit()
```
**Includes:** Memory Cache + Secure Storage + Battery Optimization

### 🎬 Media Kit
For media content and large files:
```swift
let mediaKit = ScopeGraphKits.mediaKit()
```
**Includes:** Memory Cache + Compression + Persistent Storage + Memory Optimization

### 🌐 API Cache Kit
For API response caching with network optimization:
```swift
let apiKit = ScopeGraphKits.apiCacheKit()
```
**Includes:** Memory Cache + Network Optimization + Battery Optimization

### 🔐 Secure Storage Kit
Maximum security for critical data:
```swift
let secureKit = ScopeGraphKits.secureStorageKit(service: "com.app.secure")
```
**Includes:** Secure Storage + Encryption + Battery Optimization

### 🎯 Comprehensive Kit
Full kit with all capabilities:
```swift
let fullKit = ScopeGraphKits.comprehensiveKit(service: "com.app.full")
```
**Includes:** All storage, processing, and optimization components

## 🔧 Custom Components

Create custom components by implementing `DataComponent`:

```swift
struct CustomAnalyticsComponent: DataComponent {
    typealias Input = AnalyticsEvent
    typealias Output = AnalyticsResult
    
    let identifier = "custom_analytics"
    
    func process(_ input: AnalyticsEvent) async throws -> AnalyticsResult {
        // Your processing logic
        return .processed
    }
}

// Use in pipeline
let pipeline = ScopeGraph()
    .register(CustomAnalyticsComponent())
    .register(StorageModule.persistent())
    .build()
```

## 🎨 Usage Examples

### User System
```swift
struct UserManager {
    private let pipeline = ScopeGraphKits.userDataKit()
    
    func saveUser(_ user: User) async throws {
        try await pipeline.store(user, forKey: "user_\(user.id)")
    }
    
    func getUser(id: String) async throws -> User? {
        return try await pipeline.retrieve(forKey: "user_\(id)", as: User.self)
    }
}
```

### Media Manager
```swift
struct MediaManager {
    private let pipeline = ScopeGraphKits.mediaKit()
    
    func cacheImage(_ data: Data, for url: URL) async throws {
        try await pipeline.store(data, forKey: url.absoluteString)
    }
    
    func getCachedImage(for url: URL) async throws -> Data? {
        return try await pipeline.retrieve(forKey: url.absoluteString, as: Data.self)
    }
}
```

### API Client with Caching
```swift
struct APIClient {
    private let cache = ScopeGraphKits.apiCacheKit()
    
    func fetchUsers() async throws -> [User] {
        let cacheKey = "api_users"
        
        // Check cache
        if let cached = try await cache.retrieve(forKey: cacheKey, as: [User].self) {
            return cached
        }
        
        // Load from server
        let users = try await loadUsersFromServer()
        try await cache.store(users, forKey: cacheKey)
        
        return users
    }
}
```

## 🧪 Testing

Each component is easily testable in isolation:

```swift
func testCacheComponent() async throws {
    let cache = StorageModule.memory<String, String>()
    
    try await cache.store("test_value", forKey: "test_key")
    let result = try await cache.retrieve(forKey: "test_key", as: String.self)
    
    XCTAssertEqual(result, "test_value")
}
```

## 📊 Performance

- **Modular**: Only needed components are loaded
- **Optimized**: Automatic adaptation to device conditions
- **Cached**: Multi-level caching for maximum speed
- **Compressed**: Automatic compression when needed

## 🔒 Security

- **Keychain**: Secure storage in system keychain
- **Encryption**: Additional encryption for critical data
- **Biometrics**: Touch ID/Face ID support for access
- **Isolated**: Each component is isolated from others

## 📚 Documentation

- [Getting Started](Source/ScopeGraph/Documentation.docc/GettingStarted.md)
- [Caching Guide](Source/ScopeGraph/Documentation.docc/CachingGuide.md)
- [Keychain Guide](Source/ScopeGraph/Documentation.docc/KeychainGuide.md)
- [API Reference](https://your-org.github.io/scope-graph/documentation/scopegraph/)

## 🎯 Requirements

- iOS 17.0+ / macOS 15.0+ / tvOS 15.0+ / watchOS 9.0+ / visionOS 1.0+
- Swift 6.0+
- Xcode 16.0+

## 📦 Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/your-org/scope-graph.git", from: "2.0.0")
]
```

## 🤝 Contributing

Contributions welcome! Read [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.