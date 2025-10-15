# Swift REST API Client Generation Instructions for Local LLM

## Overview
This document provides comprehensive instructions for generating a production-ready Swift REST API client using the swift-endpoint DSL library. The generated client will be type-safe, async/await compatible, and include proper authentication management.

## Single Inference Generation
**IMPORTANT**: This is designed for "one-shot" inference where the LLM receives API documentation as input and outputs complete, compilable Swift files without access to external libraries or compilation feedback.

## Required Context
### swift-endpoint Library Essentials
The swift-endpoint library provides a fluent DSL for HTTP requests. Key components:

```swift
// Core imports required
import Foundation
import Endpoint

// Basic endpoint structure
Endpoint(baseURL: URL)
    .get("path")           // HTTP methods: .get, .post, .put, .delete
    .parameter(key: "key", value: "value")  // Query parameters
    .body(object, encoder: encoder)          // Request body
    .authenticate(with: authenticator)       // Authentication
    .session(session)                        // Session management
    .call(decoder: decoder, isDataWrapped: false)  // Execute request
```

### Required Protocol Conformances
- `EndpointBuilder`: Main protocol for the client class
- `@unchecked Sendable`: Thread safety marker
- `SessionProtocol`: For session management
- `Codable`: For all data models

### Authentication Types
```swift
// Authenticator types (assume these exist in swift-endpoint)
ProxyAuthenticator()                    // Proxy for different auth types
UnauthenticatedAuthenticator()          // No authentication
BearerTokenAuthenticator(tokenProvider:) // Bearer token auth
AutoRefreshAuthenticator(tokenProvider:refreshAction:) // Auto-refresh tokens
```

## Input Requirements
- **API_REFERENCE.md**: Complete API documentation with endpoints, request/response formats, authentication requirements
- **Base URL**: API server URL (e.g., `http://localhost:8080`)
- **Target**: Swift with swift-endpoint library

## Output Files Structure

### 1. Main Client File (RestEndpoint.swift)
**Complete file template:**
```swift
import Foundation
import Endpoint

public final class RestEndpoint: EndpointBuilder, @unchecked Sendable {
    internal let baseURL: URL
    internal let authenticator: ProxyAuthenticator
    internal let session: SessionProtocol

    internal init(baseURL: URL, session: SessionProtocol) {
        self.baseURL = baseURL
        self.authenticator = ProxyAuthenticator()
        self.session = session
    }
    
    // Authentication management methods
    // API endpoint methods grouped by functionality
    // JSON encoder/decoder configuration
}
```

### 2. Data Models File (RestEndpoint+Raw.swift)
**Complete file template:**
```swift
import Foundation

extension RestEndpoint {
    // Common enums and pagination types
    // Request models for POST/PUT endpoints
    // Response models for all API responses
}
```

## Detailed Instructions

### API Documentation Analysis

1. **Extract basic information:**
   - API base URL
   - API version
   - Authentication types (API Key, Bearer Token)
   - User roles and their access rights

2. **Categorize endpoints by groups:**
   - System (health check)
   - Authentication (register, login)
   - Public (products, cars, news without authorization)
   - Protected (require Bearer Token)
   - Administrative (only for specific roles)

3. **Define data structures:**
   - Request models for POST/PUT requests
   - Response models for all responses
   - Enum types for categories, roles, statuses
   - Pagination structures

### Main File Generation (RestEndpoint.swift)

#### Basic class structure:
```swift
public final class RestEndpoint: EndpointBuilder, @unchecked Sendable {
    internal let baseURL: URL
    internal let authenticator: ProxyAuthenticator
    internal let session: SessionProtocol

    internal init(baseURL: URL, session: SessionProtocol) {
        self.baseURL = baseURL
        self.authenticator = ProxyAuthenticator()
        self.session = session
    }
}
```

#### Authentication management methods:
```swift
// MARK: - Authentication Management

public func setUnauthenticated() {
    authenticator.setAuthenticator(UnauthenticatedAuthenticator())
}

public func setBearerToken(provider: @escaping () async -> String?) {
    authenticator.setAuthenticator(BearerTokenAuthenticator(tokenProvider: provider))
}

public func setAutoRefreshToken(
    tokenProvider: @escaping () async -> String?,
    refreshAction: @escaping () async throws -> Void
) {
    let autoRefreshAuth = AutoRefreshAuthenticator(
        tokenProvider: tokenProvider,
        refreshAction: refreshAction
    )
    authenticator.setAuthenticator(autoRefreshAuth)
}
```

#### API method generation rules:

1. **Grouping by functionality:**
   ```swift
   // MARK: - System Health
   // MARK: - Authentication & Account Management
   // MARK: - QR Code Operations
   // MARK: - Product Catalog
   // MARK: - Car Catalog
   // MARK: - News & Articles
   // MARK: - Promotional Campaigns
   // MARK: - Point Transactions
   // MARK: - Company Analytics
   ```

2. **Template for GET requests without parameters:**
   ```swift
   func methodName() async throws -> RestEndpoint.ResponseType {
       try await Endpoint(baseURL: baseURL)
           .get("endpoint")
           .session(session)
           .call(decoder: Self.jsonDecoder, isDataWrapped: false)
   }
   ```

3. **Template for GET requests with pagination:**
   ```swift
   func methodName(_ pagination: RestEndpoint.PaginationRequest = RestEndpoint.PaginationRequest()) async throws -> RestEndpoint.ResponseType {
       var endpoint = Endpoint(baseURL: baseURL)
           .get("endpoint")
           .session(session)
       
       if let limit = pagination.limit {
           endpoint = endpoint.parameter(key: "limit", value: String(limit))
       }
       if let offset = pagination.offset {
           endpoint = endpoint.parameter(key: "offset", value: String(offset))
       }
       
       return try await endpoint.call(decoder: Self.jsonDecoder, isDataWrapped: false)
   }
   ```

4. **Template for POST requests:
   ```swift
   func methodName(_ request: RestEndpoint.RequestType) async throws -> RestEndpoint.ResponseType {
       try await Endpoint(baseURL: baseURL)
           .post("endpoint")
           .body(request, encoder: Self.jsonEncoder)
           .authenticate(with: authenticator) // if authentication required
           .session(session)
           .call(decoder: Self.jsonDecoder, isDataWrapped: false)
   }
   ```

5. **Template for DELETE requests:**
   ```swift
   func methodName(_ id: String) async throws -> RestEndpoint.SuccessResponse {
       try await Endpoint(baseURL: baseURL)
           .delete("endpoint/\(id)")
           .authenticate(with: authenticator)
           .session(session)
           .call(decoder: Self.jsonDecoder, isDataWrapped: false)
   }
   ```

#### JSON configuration:
```swift
// MARK: - JSON Configuration
internal extension RestEndpoint {
    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
}
```

### Data Models File Generation (RestEndpoint+Raw.swift)

#### File structure:
```swift
import Foundation

// MARK: - RestEndpoint Data Models
extension RestEndpoint {
    
    // MARK: - Common Types
    // MARK: - Request Models  
    // MARK: - Response Models
}
```

#### Model creation rules:

1. **Common types (at the beginning of file):**
   - `PaginationRequest` and `PaginationResponse`
   - Enum types for roles, statuses, categories
   - Base structures

2. **Request models:**
   - For each POST/PUT endpoint
   - All fields as `public let`
   - Initializers with default parameters where possible
   - `CodingKeys` for snake_case conversion if needed

3. **Response models:**
   - For each API response type
   - All fields as `public let`
   - Optional fields where API may not return value
   - `CodingKeys` for snake_case conversion

#### Structure template:
```swift
/// Structure description
public struct StructureName: Codable {
    /// Field description
    public let fieldName: Type
    /// Optional field
    public let optionalField: Type?
    
    private enum CodingKeys: String, CodingKey {
        case fieldName = "field_name"
        case optionalField = "optional_field"
    }
    
    public init(fieldName: Type, optionalField: Type? = nil) {
        self.fieldName = fieldName
        self.optionalField = optionalField
    }
}
```

#### Special cases:

1. **Enum types:**
   ```swift
   public enum EnumName: String, Codable, CaseIterable {
       case value1 = "value1"
       case value2 = "value2"
   }
   ```

2. **Nested structures:**
   ```swift
   public struct ParentStruct: Codable {
       public let nestedField: NestedStruct
   }
   
   public struct NestedStruct: Codable {
       public let field: String
   }
   ```

3. **Generic responses:**
   ```swift
   public struct SuccessResponse: Codable {
       public let success: Bool
       public let message: String?
       public let error: String?
   }
   ```

### Naming Rules

1. **API methods:**
   - GET lists: `getItems()`, `getProducts()`
   - GET with ID: `getItem(id:)`
   - POST creation: `createItem()`, `addProduct()`
   - DELETE: `deleteItem(id:)`
   - Special: `scanQRCode()`, `login()`, `register()`

2. **Data structures:**
   - Request: `ItemCreateRequest`, `LoginCredentials`
   - Response: `ItemsResponse`, `AuthResponse`
   - Models: `Item`, `Product`, `User`

3. **Structure fields:**
   - camelCase in Swift
   - snake_case in JSON (via CodingKeys)

### Error Handling and Special Cases

1. **Authentication:**
   - Public endpoints: without `.authenticate(with: authenticator)`
   - Protected endpoints: with `.authenticate(with: authenticator)`

2. **Pagination:**
   - Always optional parameters with default values
   - Check for nil before adding parameters

3. **Optional fields:**
   - In Request models: default parameters in initializer
   - In Response models: optional types

### Quality Control

1. **Check compliance:**
   - All endpoints from documentation are covered
   - Correct HTTP methods
   - Proper authentication
   - All data structures defined

2. **Check consistency:**
   - Unified naming style
   - Correct data types
   - Proper CodingKeys

3. **Check completeness:**
   - All fields from API documentation included
   - Correct types (String, Int, Bool, Array, etc.)
   - Optionality matches API

### Complete Generation Example

For endpoint `POST /register`:

**In RestEndpoint.swift:**
```swift
func register(_ request: RestEndpoint.UserRegistration) async throws -> RestEndpoint.AuthResponse {
    try await Endpoint(baseURL: baseURL)
        .post("register")
        .body(request, encoder: Self.jsonEncoder)
        .session(session)
        .call(decoder: Self.jsonDecoder, isDataWrapped: false)
}
```

**In RestEndpoint+Raw.swift:**
```swift
public struct UserRegistration: Codable {
    public let name: String
    public let email: String
    public let password: String
    public let userType: UserType
    
    public init(name: String, email: String, password: String, userType: UserType) {
        self.name = name
        self.email = email
        self.password = password
        self.userType = userType
    }
}

public struct AuthResponse: Codable {
    public let success: Bool
    public let user: UserProfile?
    public let token: String?
    public let error: String?
}
```

## Swift-Endpoint Library Context

### Core Components (Assume Available)
```swift
// These types exist in swift-endpoint library:
protocol EndpointBuilder { }
protocol SessionProtocol { }
class ProxyAuthenticator {
    func setAuthenticator(_ auth: any Authenticator)
}
class UnauthenticatedAuthenticator: Authenticator { }
class BearerTokenAuthenticator: Authenticator {
    init(tokenProvider: @escaping () async -> String?)
}
class AutoRefreshAuthenticator: Authenticator {
    init(tokenProvider: @escaping () async -> String?, refreshAction: @escaping () async throws -> Void)
}
struct Endpoint {
    init(baseURL: URL)
    func get(_ path: String) -> Self
    func post(_ path: String) -> Self
    func put(_ path: String) -> Self
    func delete(_ path: String) -> Self
    func parameter(key: String, value: String) -> Self
    func body<T: Encodable>(_ object: T, encoder: JSONEncoder) -> Self
    func authenticate(with: any Authenticator) -> Self
    func session(_ session: SessionProtocol) -> Self
    func call<T: Decodable>(decoder: JSONDecoder, isDataWrapped: Bool) async throws -> T
}
```

## Generation Output Requirements

### Must Include All Imports
```swift
// RestEndpoint.swift
import Foundation
import Endpoint

// RestEndpoint+Raw.swift  
import Foundation
```

### Must Be Compilation-Ready
- All types properly defined
- All methods have correct signatures
- All imports included
- Proper access modifiers (public/internal/private)
- Complete initializers for all structs

## Final Output Validation

**The LLM must ensure the generated code:**

1. **Compiles without errors** - All types, imports, and method signatures are correct
2. **Complete API coverage** - Every endpoint from documentation has corresponding method
3. **Proper authentication** - Public endpoints without auth, protected endpoints with auth
4. **Type safety** - All request/response models match API documentation exactly
5. **Consistent naming** - Follows Swift conventions and patterns shown in examples
6. **Self-contained** - No external dependencies beyond Foundation and Endpoint
7. **Production ready** - Includes error handling, optional parameters, proper documentation

## LLM Prompt Structure

**Effective prompt format:**
```
Generate a complete Swift REST API client using swift-endpoint DSL based on this API documentation:

[INSERT API_REFERENCE.md CONTENT]

Requirements:
- Base URL: [URL]
- Generate RestEndpoint.swift (main client)
- Generate RestEndpoint+Raw.swift (data models)
- Must compile without errors
- Include all endpoints from documentation
- Use proper authentication for protected endpoints
- Follow the templates and patterns provided in the instructions

Output both files with complete, compilable Swift code.
```

Following these instructions, a local LLM model will generate production-ready, compilable Swift REST API clients in a single inference without external dependencies or feedback loops.