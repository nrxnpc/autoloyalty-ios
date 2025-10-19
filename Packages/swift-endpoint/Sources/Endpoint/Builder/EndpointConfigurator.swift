import Foundation

// MARK: - Request Chain Builder

/// A fluent builder that configures and executes a single API request.
///
/// This object is the heart of the DSL, created via the global `Endpoint(baseURL:)` function.
/// It holds the complete configuration for a single, self-contained API request.
///
/// The builder is designed to be immutable; each configuration method returns a new,
/// modified instance, allowing for safe and predictable request construction.
public struct EndpointConfigurator: SessionBuilder {
    
    // MARK: Private State
    private var baseURL: URL
    private var pathComponents: [String]
    private var method: HTTPMethod
    private var headers: [String: String]
    private var queryItems: [URLQueryItem]
    private var body: Data?
    private var session: SessionProtocol
    private var authenticator: (any Authenticator)?

    /// Initializes the configurator with a base URL.
    /// Kept `fileprivate` to ensure creation via the global `Endpoint()` function.
    init(baseURL: URL) {
        self.baseURL = baseURL
        self.pathComponents = []
        self.method = .get // Default method
        self.headers = [:]
        self.queryItems = []
        self.session = EndpointConfigurator.createSession()
    }

    // MARK: - Fluent Configuration Methods
    
    /// Appends a path component to the URL.
    ///
    /// Can be called multiple times to build a nested path (e.g., `.path("users").path("123")`).
    /// - Parameter component: The path component string to add.
    public func path(_ component: String) -> Self {
        var new = self
        new.pathComponents.append(component)
        return new
    }
    
    /// Sets the HTTP method to GET and optionally appends a final path component.
    public func get(_ path: String = "") -> Self {
        var new = self
        new.method = .get
        if !path.isEmpty { new.pathComponents.append(path) }
        return new
    }

    /// Sets the HTTP method to POST and optionally appends a final path component.
    public func post(_ path: String = "") -> Self {
        var new = self
        new.method = .post
        if !path.isEmpty { new.pathComponents.append(path) }
        return new
    }

    /// Sets the HTTP method to PUT and optionally appends a final path component.
    public func put(_ path: String = "") -> Self {
        var new = self
        new.method = .put
        if !path.isEmpty { new.pathComponents.append(path) }
        return new
    }

    /// Sets the HTTP method to DELETE and optionally appends a final path component.
    public func delete(_ path: String = "") -> Self {
        var new = self
        new.method = .delete
        if !path.isEmpty { new.pathComponents.append(path) }
        return new
    }

    /// Sets the HTTP method to PATCH and optionally appends a final path component.
    public func patch(_ path: String = "") -> Self {
        var new = self
        new.method = .patch
        if !path.isEmpty { new.pathComponents.append(path) }
        return new
    }
    
    /// Adds a URL query parameter.
    /// - Parameters:
    ///   - key: The name of the query parameter.
    ///   - value: The optional value. If `nil`, the key is added without a value (e.g., `?is_enabled`).
    public func parameter(key: String, value: String?) -> Self {
        var new = self
        new.queryItems.append(URLQueryItem(name: key, value: value))
        return new
    }
    
    /// Sets the request body by encoding an `Encodable` object into JSON.
    ///
    /// This method also automatically sets the `Content-Type` header to `application/json; charset=utf-8`.
    /// - Parameters:
    ///   - data: The `Encodable` object to use as the request body.
    ///   - encoder: A `JSONEncoder` to use for encoding. Defaults to a standard encoder.
    public func body<T: Encodable>(_ data: T, encoder: JSONEncoder = JSONEncoder()) -> Self {
        var new = self
        new.body = try? encoder.encode(data)
        new.headers["Content-Type"] = "application/json; charset=utf-8"
        return new
    }

    /// Applies an authentication strategy to the request.
    /// - Parameter authenticator: An object conforming to the `Authenticator` protocol.
    public func authenticate(with authenticator: any Authenticator) -> Self {
        var new = self
        new.authenticator = authenticator
        return new
    }
    
    /// Specifies a custom `URLSession` for this request.
    /// - Parameter session: The `URLSession` instance to use.
    public func session(_ session: SessionProtocol) -> Self {
        var new = self
        new.session = session
        return new
    }
    
    // MARK: - Request Execution
    
    /// **Query:** Executes the request and decodes the response into a `Decodable` type.
    /// Automatically unwraps data from API wrapper structure.
    /// - Parameter decoder: A `JSONDecoder` to use for decoding the response.
    /// - Parameter wrappedData: root node of the JSON response is a `data`
    /// - Returns: An instance of the specified `Decodable` type.
    public func call<T: Decodable & Sendable>(decoder: JSONDecoder = JSONDecoder(), isDataWrapped: Bool = true) async throws -> T {
        let (data, _) = try await executeRequestWithRetry()
        if data.isEmpty { throw EndpointError.noData }
        do {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if isDataWrapped {
                return try decoder.decode(APIResponseWrapper<T>.self, from: data).data
            } else {
                return try decoder.decode(T.self, from: data)
            }
        } catch let error {
            debugPrint("[DEBUG][Endpoint] Response decoding error: \(error)")
            throw EndpointError.decodingFailed(error)
        }
    }
    
    /// **Command:** Executes the request and returns on success or throws an error on failure.
    public func call() async throws {
        _ = try await executeRequestWithRetry()
    }
    
    // MARK: - Private Helpers
    
    private func executeRequestWithRetry() async throws -> (Data, HTTPURLResponse) {
        do {
            return try await executeRequest()
        } catch EndpointError.unexpectedStatusCode(401) {
            // Handle 401 Unauthorized - attempt token refresh
            if let refreshableAuth = authenticator as? RefreshableAuthenticator {
                try await refreshableAuth.handleUnauthorized()
                // Retry request with refreshed token
                return try await executeRequest()
            }
            throw EndpointError.unexpectedStatusCode(401)
        }
    }
    
    private func executeRequest() async throws -> (Data, HTTPURLResponse) {
        let request = try await buildRequest()
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await self.session.data(for: request)
        } catch {
            // Wrap network-level errors for consistency
            throw EndpointError.requestFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            // Should not happen with HTTP requests, but good to handle
            throw EndpointError.unexpectedStatusCode(-1)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw EndpointError.unexpectedStatusCode(httpResponse.statusCode)
        }
        
        return (data, httpResponse)
    }
    
    private func buildRequest() async throws -> URLRequest {
        let fullPath = pathComponents.filter { !$0.isEmpty }.joined(separator: "/")
        var finalURL = baseURL.appendingPathComponent(fullPath)
        
        if !queryItems.isEmpty {
            guard var components = URLComponents(url: finalURL, resolvingAgainstBaseURL: false) else {
                throw EndpointError.invalidURL(fullPath)
            }
            components.queryItems = (components.queryItems ?? []) + queryItems
            if let urlWithQuery = components.url {
                finalURL = urlWithQuery
            }
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        if let authenticator = self.authenticator {
            do {
                try await authenticator.authenticate(request: &request)
            } catch {
                throw EndpointError.authenticationFailed(error)
            }
        }
        return request
    }
}

// MARK: - Private API Response Wrapper

/// A private wrapper for API responses where the main content is nested under a "data" key.
private struct APIResponseWrapper<T: Decodable & Sendable>: Decodable, Sendable {
    let data: T
}

// MARK: - Core Networking Components

/// An enumeration of HTTP methods to ensure type safety.
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

/// Custom error types for the networking layer.
enum EndpointError: Error, LocalizedError {
    case invalidURL(String)
    case authenticationFailed(Error)
    case requestFailed(Error)
    case unexpectedStatusCode(Int)
    case decodingFailed(Error)
    case noData

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let path): return "The provided URL path was invalid: \(path)"
        case .authenticationFailed(let error): return "Authentication failed: \(error.localizedDescription)"
        case .requestFailed(let error): return "The network request failed: \(error.localizedDescription)"
        case .unexpectedStatusCode(let code): return "Received an unexpected HTTP status code: \(code)"
        case .decodingFailed(let error): return "Failed to decode the response: \(error.localizedDescription)"
        case .noData: return "The server returned no data."
        }
    }
}
