//
//  RestEndpoint+Dependency.swift
//
import Dependencies
import Foundation

// MARK: - ResourceEndpoint Dependency

extension DependencyValues {
    /// Provides access to a `RestEndpoint` instance.
    ///
    /// This dependency is reactive. It automatically provides an endpoint configured
    /// with the correct `Authenticator` based on the current `SessionState` managed
    /// by `ApplicationScope`.
    public var endpoint: RestEndpoint {
        get { self[EndpointContextKey.self] }
        set { self[EndpointContextKey.self] = newValue }
    }
}

private enum EndpointContextKey: DependencyKey {
    static var liveValue: RestEndpoint {
        RestEndpoint(baseURL: URL(string: "http://locahost:8080")!)
    }
}
