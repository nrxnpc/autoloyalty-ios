import Foundation
import Endpoint
import ScopeGraph
import CoreData

// MARK: - Grab Functions

// MARK: - Authentication

public extension Scope {
    /// Universal point to add data to scope graph using function overloading polymorphism.
    /// The grab pattern provides a consistent interface for processing different types of API responses
    /// and integrating them into the application's data pipeline and scope graph.
    ///
    /// - Parameter operation: Async operation that returns a LoginResponse
    /// - Throws: Authentication or network errors
    
    // Example: 
    // @MainActor
    // func grab(_ operation: @escaping @Sendable () async throws -> RestEndpoint.LoginResponse) async throws {
    //     let loginResponse = try await operation()
    //     do {
    //         let loginUseCase = LoginUseCase(scope: self)
    //         try await loginUseCase.execute(loginResponse)
    //     } catch let error {
    //         debugPrint("[DEBUG] Failed to login: \(error)")
    //     }
    // }
}
