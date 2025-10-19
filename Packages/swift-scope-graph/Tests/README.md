# ScopeGraph Tests

Comprehensive test suite demonstrating ScopeGraph functionality and serving as executable documentation.

## Test Structure

### 🗂️ CacheTests
**Purpose**: Cache system functionality and performance optimization  
**Coverage**: Memory management, expiration, size limits, persistence

Key scenarios:
- Basic cache operations (insert, retrieve, remove)
- Subscript convenience syntax
- Automatic expiration and cleanup
- Size-based eviction policies
- Thread-safe concurrent access
- Cache persistence to disk

### 🔐 KeychainTests  
**Purpose**: Secure keychain storage and retrieval operations  
**Coverage**: Security levels, biometric protection, error handling

Key scenarios:
- Basic keychain operations (store, retrieve, remove)
- Binary data storage and retrieval
- Security accessibility configuration
- Biometric authentication requirements
- Keychain item attributes and metadata
- Error handling and recovery

### 🏗️ ScopeGraphBuilderTests
**Purpose**: Architecture patterns and component organization  
**Coverage**: Builder pattern, data manager structures, integration

Key scenarios:
- ScopeGraphBuilder protocol conformance
- Data manager component organization
- Integration between cache, keychain, and persistence
- Comprehensive data management patterns

## Running Tests

### Command Line
```bash
# Run all tests
swift test

# Run specific test class
swift test --filter CacheTests

# Run with verbose output
swift test --verbose
```

### Xcode
1. Open Package.swift in Xcode
2. Select the test target
3. Use ⌘+U to run all tests
4. Use ⌘+Ctrl+U to run tests with coverage

## Test Categories

### Unit Tests
- **Cache functionality** - Memory management, expiration, limits
- **Keychain operations** - Secure storage, retrieval, configuration
- **Builder patterns** - Architecture and organization

### Integration Tests
- **Component interaction** - Cache + Keychain + Persistence
- **Data flow** - End-to-end data management scenarios
- **Error handling** - Cross-component error propagation

### Performance Tests
- **Cache performance** - Large dataset handling, memory efficiency
- **Keychain performance** - Bulk operations, concurrent access
- **Memory usage** - Leak detection, optimization verification

## Test Data

### Mock Objects
- `UserProfile` - Example user data model
- `CacheDataManager` - Cache-focused data management
- `KeychainDataManager` - Security-focused data management
- `ComprehensiveDataManager` - Full-stack data management

### Test Scenarios
- **Happy path** - Normal operation flows
- **Edge cases** - Boundary conditions and limits
- **Error conditions** - Failure scenarios and recovery
- **Performance** - Load testing and optimization

## Best Practices

### Test Organization
- One test class per major component
- Descriptive test method names explaining the scenario
- Clear Given/When/Then structure in test methods
- Comprehensive setup and teardown

### Test Data Management
- Use unique identifiers to avoid test interference
- Clean up test data in tearDown methods
- Use realistic but safe test data
- Avoid hardcoded values where possible

### Assertions
- Test both positive and negative cases
- Verify error conditions and messages
- Check side effects and state changes
- Use appropriate assertion methods for clarity

## Coverage Goals

- **Line Coverage**: >90% for core functionality
- **Branch Coverage**: >85% for decision points
- **API Coverage**: 100% for public interfaces
- **Error Path Coverage**: >80% for error handling

## Continuous Integration

Tests are automatically run on:
- Pull request creation and updates
- Main branch commits
- Release tag creation
- Nightly builds for performance regression detection