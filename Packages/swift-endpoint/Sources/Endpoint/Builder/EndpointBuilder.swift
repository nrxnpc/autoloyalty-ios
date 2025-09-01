import Foundation

// MARK: - EndpointBuilder Protocol

/// A marker protocol for creating type-safe API client namespaces.
///
/// Use this protocol to organize related API endpoints into cohesive units.
/// This improves code organization and provides better discoverability.
///
/// ## Usage
///
/// ```swift
/// struct UserAPI: EndpointBuilder {
///     let baseURL: URL
///     let auth: Authenticator
///     
///     func getUsers() async throws -> [User] {
///         try await Endpoint(baseURL: baseURL)
///             .get("users")
///             .authenticate(with: auth)
///             .call()
///     }
///     
///     func createUser(_ user: CreateUserRequest) async throws -> User {
///         try await Endpoint(baseURL: baseURL)
///             .post("users")
///             .body(user)
///             .authenticate(with: auth)
///             .call()
///     }
/// }
/// ```
public protocol EndpointBuilder { }

// MARK: - Public Entry Point

/// Creates a new HTTP request builder with fluent interface.
///
/// This is the main entry point for building HTTP requests. It returns an
/// ``EndpointConfigurator`` that allows you to chain method calls to build
/// your request configuration.
///
/// ## Basic Usage
///
/// ```swift
/// // Simple GET request
/// let users: [User] = try await Endpoint(baseURL: apiURL)
///     .get("users")
///     .call()
///
/// // POST with JSON body
/// try await Endpoint(baseURL: apiURL)
///     .post("users")
///     .body(newUser)
///     .call()
///
/// // Authenticated request with query parameters
/// let tasks: [Task] = try await Endpoint(baseURL: apiURL)
///     .get("tasks")
///     .parameter(key: "status", value: "active")
///     .authenticate(with: bearerAuth)
///     .call()
/// ```
///
/// - Parameter baseURL: The base URL for the API (e.g., `https://api.example.com/v1`)
/// - Returns: A configured ``EndpointConfigurator`` for building the request
public func Endpoint(baseURL: URL) -> EndpointConfigurator {
    return EndpointConfigurator(baseURL: baseURL)
}
