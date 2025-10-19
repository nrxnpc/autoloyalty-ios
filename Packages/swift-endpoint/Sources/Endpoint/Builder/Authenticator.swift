import Foundation

// TODO: how ot handkle refreesh token error? implement and shjow example of implementation in docs 

// MARK: - Authenticator Protocol

/// A protocol defining an asynchronous authentication strategy for a network request.
///
/// An `Authenticator` is responsible for modifying a `URLRequest` in-place to add
/// authentication details, such as an `Authorization` header.
public protocol Authenticator {
    /// Asynchronously authenticates a URL request.
    /// - Parameter request: The `URLRequest` to be modified. This is an `inout` parameter.
    /// - Throws: An error if the authentication process fails (e.g., cannot retrieve a token).
    func authenticate(request: inout URLRequest) async throws
}


// MARK: - Concrete Implementations

/// An `Authenticator` for adding a Bearer token to the `Authorization` header.
///
/// This implementation is initialized with a closure that provides the token. This decouples
/// the authenticator from the token storage mechanism (e.g., Keychain, user defaults),
/// making it highly reusable and testable.
///
/// ### Token Refresh Strategy
/// This authenticator does not handle token refreshing automatically. The recommended pattern is
/// for the API client layer (e.g., `ResourceEndpoint`) to catch an `EndpointError.unexpectedStatusCode(401, _)`
/// error, execute a token refresh request, and then retry the original failed request with a new
/// instance of the API client containing the updated authenticator.
public struct BearerTokenAuthenticator: Authenticator {
    public enum AuthError: Error, LocalizedError {
        case tokenNotAvailable
        
        public var errorDescription: String? {
            "Bearer token could not be provided."
        }
    }
    
    /// A closure that asynchronously returns the bearer token string.
    private let tokenProvider: () async -> String?
    
    /// Creates a new Bearer token authenticator.
    /// - Parameter tokenProvider: A closure that returns the current token. It can be `async`.
    public init(tokenProvider: @escaping () async -> String?) {
        self.tokenProvider = tokenProvider
    }
    
    public func authenticate(request: inout URLRequest) async throws {
        guard let token = await tokenProvider() else {
            throw AuthError.tokenNotAvailable
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}

// MARK: - Unauthenticated Implementation

/// An `Authenticator` that represents an unauthenticated session.
///
/// This implementation serves as a "guard" or "null object". Its purpose is to explicitly
/// represent a state where no user is logged in.
///
/// When `authenticate(request:)` is called, it will **always** throw an error. This prevents
/// accidental network requests to protected endpoints, causing the operation to fail fast
/// before a network roundtrip can occur. This is safer and more efficient than allowing
/// a request to be sent without an `Authorization` header, only to receive a `401 Unauthorized`
/// response from the server.
///
/// ### Usage
/// Use this type when you need to provide an `Authenticator` but want to enforce that
/// the session is logged out.
///
/// ```swift
/// // Create an API client for a logged-out user.
/// let unauthenticatedAPI = ResourceEndpoint(authenticator: UnauthenticatedAuthenticator())
///
/// do {
///     // This call will fail immediately with `UnauthenticatedAuthenticator.Error`.
///     try await unauthenticatedAPI.getAccount()
/// } catch {
///     print(error) // "An attempt was made to access a protected endpoint with an unauthenticated session."
/// }
/// ```
public struct UnauthenticatedAuthenticator: Authenticator {

    /// The error thrown when an attempt is made to use this authenticator.
    public enum Error: Swift.Error, LocalizedError {
        case accessAttemptedWhenUnauthenticated
        
        public var errorDescription: String? {
            "An attempt was made to access a protected endpoint with an unauthenticated session."
        }
    }
    
    /// Creates a new unauthenticated authenticator.
    public init() {}
    
    /// Throws an error to prevent the request from being sent.
    ///
    /// - Parameter request: The `URLRequest` that would have been sent. It is not modified.
    /// - Throws: `UnauthenticatedAuthenticator.Error.accessAttemptedWhenUnauthenticated`
    public func authenticate(request: inout URLRequest) async throws {
        throw Error.accessAttemptedWhenUnauthenticated
    }
}
