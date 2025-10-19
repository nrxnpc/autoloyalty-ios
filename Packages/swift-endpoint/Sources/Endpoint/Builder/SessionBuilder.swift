import Foundation

// MARK: - Session Protocol

public protocol SessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: SessionProtocol {}

/// A protocol that defines an asynchronous authentication strategy.
public protocol SessionBuilder {
}

/// An extension to provide reusable helper methods for common authentication tasks.
public extension SessionBuilder {
    /// Encapsulates the logic for setting a bearer token on a request.
    static func createSession() -> SessionProtocol {
        URLSession(configuration: .default)
    }
}
