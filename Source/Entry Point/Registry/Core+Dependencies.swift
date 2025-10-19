//
//  Core+Dependency.swift
//
import Dependencies
import Foundation

// MARK: - ApplicationScope Dependency

extension DependencyValues {
    /// Provides access to the shared `ApplicationScope` instance.
    public var scope: Scope {
        get { self[ApplicationScopeContextKey.self] }
        set { self[ApplicationScopeContextKey.self] = newValue }
    }
}

private enum ApplicationScopeContextKey: DependencyKey {
    /// The `liveValue` is the singleton instance of our application's state manager.
    static let liveValue: Scope = .init()
}
