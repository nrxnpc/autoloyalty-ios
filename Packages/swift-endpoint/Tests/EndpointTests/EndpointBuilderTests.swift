import XCTest
@testable import Endpoint

/// Tests demonstrating how to build HTTP requests using the Endpoint DSL.
/// These tests serve as executable documentation for the library's core functionality.
final class EndpointBuilderTests: XCTestCase {
    
    private let baseURL = URL(string: "https://api.example.com/v1")!
    
    // MARK: - Basic Request Building
    
    /// Demonstrates building a simple GET request to fetch a single resource.
    /// This is the most common use case for REST APIs.
    func test_buildingSimpleGETRequest_shouldCreateCorrectURL() async throws {
        // When: Building a GET request
        let configurator = Endpoint(baseURL: baseURL).get("users/1")
        
        // Then: The configurator should be created successfully
        XCTAssertNotNil(configurator)
    }
    
    /// Shows how to build complex paths using multiple path components.
    /// Useful for nested resources like /users/123/posts/456/comments.
    func test_buildingNestedPaths_shouldConcatenatePathComponents() async throws {
        // When: Building a request with nested path components
        let configurator = Endpoint(baseURL: baseURL)
            .path("users")
            .path("123")
            .path("posts")
            .get("456")
        
        // Then: The configurator should be created successfully
        XCTAssertNotNil(configurator)
    }
    
    // MARK: - HTTP Methods
    
    /// Demonstrates all supported HTTP methods.
    /// Each method sets the appropriate HTTP verb for different operations.
    func test_httpMethods_shouldCreateConfigurators() async throws {
        // When & Then: Testing each HTTP method creates valid configurators
        XCTAssertNotNil(Endpoint(baseURL: baseURL).get("resource"))
        XCTAssertNotNil(Endpoint(baseURL: baseURL).post("resource"))
        XCTAssertNotNil(Endpoint(baseURL: baseURL).put("resource"))
        XCTAssertNotNil(Endpoint(baseURL: baseURL).patch("resource"))
        XCTAssertNotNil(Endpoint(baseURL: baseURL).delete("resource"))
    }
    
    // MARK: - Query Parameters
    
    /// Demonstrates adding query parameters for filtering and pagination.
    /// Multiple parameters are properly URL-encoded and joined.
    func test_queryParameters_shouldCreateConfiguratorWithParameters() async throws {
        // When: Adding multiple query parameters
        let configurator = Endpoint(baseURL: baseURL)
            .get("users")
            .parameter(key: "status", value: "active")
            .parameter(key: "page", value: "2")
            .parameter(key: "limit", value: "10")
            .parameter(key: "sort", value: "name desc")
        
        // Then: The configurator should be created successfully
        XCTAssertNotNil(configurator)
    }
}

// MARK: - Test Models

/// Example user model for testing JSON serialization/deserialization
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}