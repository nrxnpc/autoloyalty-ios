# Swift Endpoint Tests

This test suite serves as both validation and executable documentation for the Swift Endpoint library. Each test demonstrates real-world usage patterns and best practices.

## Test Structure

### 📋 EndpointBuilderTests
**Purpose**: Core request building functionality  
**Coverage**: HTTP methods, path construction, query parameters, request bodies

Key scenarios:
- Building simple GET requests for resource fetching
- Constructing complex nested paths (`/users/123/posts/456`)
- Adding query parameters for filtering and pagination
- Sending JSON payloads in POST/PUT requests

### 🔐 AuthenticationTests  
**Purpose**: Core authentication strategies and security patterns  
**Coverage**: Bearer tokens, custom auth, basic error handling

Key scenarios:
- JWT/Bearer token authentication with async token providers
- Custom authentication strategies (API keys, signatures)
- Fail-fast patterns for unauthenticated sessions
- Basic authentication error propagation

### 🔄 RefreshableTokenTests
**Purpose**: Automatic token refresh functionality  
**Coverage**: Thread-safe refresh, concurrent requests, retry logic

Key scenarios:
- Automatic token refresh on 401 responses
- Thread-safe handling of concurrent refresh requests
- Single refresh operation for multiple concurrent failures

### ❌ RefreshTokenErrorTests
**Purpose**: Comprehensive refresh token error handling  
**Coverage**: All refresh failure scenarios and error propagation

Key scenarios:
- Missing token availability errors
- Network failures during token refresh
- Invalid/expired refresh token handling
- Retry limit exceeded scenarios
- Concurrent refresh failure propagation

### ⚠️ ErrorHandlingTests
**Purpose**: Comprehensive error scenarios  
**Coverage**: HTTP errors, network failures, JSON parsing issues

Key scenarios:
- HTTP 4xx/5xx status code handling
- Network connectivity failures and timeouts  
- Malformed JSON response handling
- Empty response validation for different operation types

### 🔄 IntegrationTests
**Purpose**: Real-world workflows and patterns  
**Coverage**: Complete CRUD operations, authentication flows, resilience patterns

Key scenarios:
- Full user management lifecycle (create → read → update → delete)
- Login flows with token management
- Retry logic for transient failures
- Graceful degradation when optional services fail

## Running Tests

```bash
# Run all tests
swift test

# Run specific test class
swift test --filter EndpointBuilderTests

# Run with verbose output
swift test --verbose
```

## Test Philosophy

These tests follow the **executable documentation** principle:

1. **Clear naming**: Test names describe the scenario and expected outcome
2. **Comprehensive comments**: Each test explains the Given/When/Then flow
3. **Real-world scenarios**: Tests mirror actual API usage patterns
4. **Error coverage**: Both success and failure paths are tested
5. **Best practices**: Tests demonstrate recommended usage patterns

## Mock Infrastructure

The test suite uses `MockURLSession` to simulate network responses without actual HTTP calls:

- **Controllable responses**: Set custom JSON, status codes, errors
- **Request inspection**: Verify headers, methods, URLs, bodies
- **Failure simulation**: Test error handling and retry logic
- **Performance**: Fast test execution without network latency

## Coverage Goals

- ✅ All public API methods
- ✅ Error conditions and edge cases  
- ✅ Authentication strategies
- ✅ Real-world integration patterns
- ✅ Performance and reliability patterns

## Contributing

When adding new features:

1. Add corresponding test cases in the appropriate test class
2. Follow the executable documentation style
3. Include both success and failure scenarios
4. Update this README if adding new test categories