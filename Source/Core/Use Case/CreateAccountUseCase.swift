import Foundation
import ScopeGraph

public struct CreateAccountUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute(email: String, password: String, confirmationCode: String) async throws {
        let loginResponse = try await scope.endpoint.register(
            .init(name: String(email.split(separator: "@").first ?? "user"),
                  email: email,
                  phone: String(UUID().uuidString.prefix(20)),
                  password: password,
                  userType: .individual)
        )
        
        // Create session first
        let createSessionUseCase = CreateSessionUseCase(scope: scope)
        let sessionID = try await createSessionUseCase.execute(from: loginResponse)
        try await scope.switchSession(with: sessionID)
    }
}
