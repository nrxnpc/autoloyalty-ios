//
//  RestEndpoint+Dependency.swift
//
import Dependencies

// MARK: - ResourceEndpoint Dependency

extension DependencyValues {
    /// Provides access to a `ResourceEndpoint` instance.
    ///
    /// This dependency is reactive. It automatically provides an endpoint configured
    /// with the correct `Authenticator` based on the current `SessionState` managed
    /// by `ApplicationScope`.
    public var endpoint: RestEndpoint {
        get { self[ResourceEndpointContextKey.self] }
        set { self[ResourceEndpointContextKey.self] = newValue }
    }
}

private enum ResourceEndpointContextKey: DependencyKey {
    static var liveValue: RestEndpoint {
        @Dependency(\.scope) var scope
        return scope.endpoint
    }
}
