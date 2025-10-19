# ScopeGraph

A modular data processing pipeline for iOS, macOS, watchOS, tvOS, and visionOS applications built with Swift 6 and modern concurrency.

## Overview

ScopeGraph provides a flexible, type-safe data processing pipeline with support for caching, persistent storage, secure keychain operations, and CoreData integration. Built from the ground up for Swift 6 concurrency with full Sendable compliance.

## Features

- **Modular Architecture**: Compose data processing pipelines from reusable components
- **Type Safety**: Full generic support with compile-time type checking
- **Swift 6 Ready**: Complete Sendable conformance and strict concurrency support
- **Multi-Platform**: iOS 18+, macOS 15+, watchOS 11+, tvOS 18+, visionOS 2+
- **Async/Await**: Modern concurrency throughout the entire API
- **CoreData Integration**: User-specific databases with automatic migration
- **Secure Storage**: Keychain integration for sensitive data
- **High Performance**: Optimized caching with automatic expiration

## Requirements

- iOS 18.0+ / macOS 15.0+ / watchOS 11.0+ / tvOS 18.0+ / visionOS 2.0+
- Swift 6.0+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add ScopeGraph to your project using Xcode or by adding it to your `Package.swift`:

```swift
dependencies: [
    .package(path: "Packages/swift-scope-graph")
]
```

## Quick Start

### Basic Pipeline Setup

```swift
import ScopeGraph

// Create a simple caching pipeline
let pipeline = ScopeGraph()
    .register(CacheComponent<String, Data>())
    .build()

// Store data
try await pipeline.store(someData, forKey: "user_profile")

// Retrieve data
let data = try await pipeline.retrieve(forKey: "user_profile", as: Data.self)
```

### CoreData Integration

```swift
import ScopeGraph
import CoreData

// Setup CoreData stack
let bundle = Bundle.main
let stack = CoreDataStack(
    userId: "user123", 
    modelName: "DataModel", 
    modelBundle: bundle
)

// Create pipeline with CoreData
let pipeline = ScopeGraph()
    .register(CoreDataComponent(stack: stack))
    .register(CacheComponent<String, NSManagedObject>())
    .build()

// Access CoreData directly
let context = pipeline.coreDataStack().viewContext
```

### Advanced Configuration

```swift
// Custom cache configuration
let cacheComponent = CacheComponent<String, UserProfile>(
    entryLifetime: 30 * 60, // 30 minutes
    maximumEntryCount: 100
)

// Multi-component pipeline
let pipeline = ScopeGraph()
    .register(cacheComponent)
    .register(CoreDataComponent(stack: coreDataStack))
    .register(SecureStorageComponent())
    .build()
```

## Components

### CacheComponent

High-performance in-memory caching with automatic expiration:

```swift
let cache = CacheComponent<String, UserData>(
    entryLifetime: 12 * 60 * 60, // 12 hours
    maximumEntryCount: 50
)
```

**Features:**
- Automatic expiration based on configurable lifetime
- Memory pressure handling with LRU eviction
- Thread-safe operations
- Generic key-value storage

### CoreDataComponent

Robust CoreData integration with user-specific databases:

```swift
let stack = CoreDataStack(
    userId: "user123",
    modelName: "MyModel", 
    modelBundle: .main
)
let coreData = CoreDataComponent(stack: stack)
```

**Features:**
- User-specific SQLite databases for data isolation
- Automatic migration handling and error recovery
- In-memory storage for testing
- Background context support

### SecureStorageComponent

Keychain integration for sensitive data storage:

```swift
let secureStorage = SecureStorageComponent()

// Store sensitive data
try await secureStorage.store(tokenData, forKey: "auth_token")

// Retrieve sensitive data
let token = try await secureStorage.retrieve(forKey: "auth_token", as: Data.self)
```

## Architecture

ScopeGraph uses a modular pipeline architecture where components can be composed to create custom data processing workflows:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Application   │───▶│   DataPipeline   │───▶│   Components    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │                         │
                              ▼                         ▼
                       ┌──────────────┐         ┌─────────────┐
                       │  ScopeGraph  │         │ Cache       │
                       │  Registry    │         │ CoreData    │
                       └──────────────┘         │ Secure      │
                                               └─────────────┘
```

### Component Protocol

All components implement the `DataComponent` protocol:

```swift
public protocol DataComponent: Sendable {
    associatedtype Input: Sendable
    associatedtype Output: Sendable
    
    func process(_ input: Input) async throws -> Output
    var identifier: String { get }
}
```

## Testing

ScopeGraph provides excellent testing support with in-memory components:

```swift
// In-memory CoreData for testing
let testStack = CoreDataStack.inMemory(
    userId: "test_user",
    modelName: "TestModel", 
    model: testModel
)

// Test pipeline
let testPipeline = ScopeGraph()
    .register(CoreDataComponent(stack: testStack))
    .register(CacheComponent<String, TestData>())
    .build()
```

## Performance

ScopeGraph is optimized for performance:

- **Zero-copy operations** where possible
- **Lazy initialization** of expensive resources
- **Automatic memory management** with configurable limits
- **Background processing** support for heavy operations

## Thread Safety

All ScopeGraph components are thread-safe and Sendable-compliant:

- Components can be safely passed between actors
- Concurrent access is handled internally
- No external synchronization required

## Migration Guide

### From Earlier Versions

ScopeGraph 2.0 introduces breaking changes for Swift 6 compatibility:

1. **Sendable Conformance**: All types now conform to Sendable
2. **Availability Annotations**: Minimum deployment targets updated
3. **Async/Await**: All operations are now async
4. **Strict Concurrency**: Full compliance with Swift 6 concurrency model

## Contributing

We welcome contributions! Please see our contributing guidelines for details.

## License

ScopeGraph is available under the MIT license. See LICENSE for details.

## Support

- **Documentation**: [Full API Documentation](Documentation.docc/)
- **Issues**: Report bugs and feature requests on GitHub
- **Discussions**: Join our community discussions

---

Built with ❤️ for the Swift community