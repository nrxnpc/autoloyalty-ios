import Foundation
import ScopeGraph

public struct CreateAccountUseCase {
    private let scope: Scope
    
    public enum CreateAccountError: Error {
        case registrationFailed
    }
    
    public init(scope: Scope) {
        self.scope = scope
    }
    
    /// Step 1: Request registration - sends verification code to email
    public func requestRegistration(name: String, email: String, password: String) async throws {
        let response = try await scope.endpoint.registerRequest(
            .init(name: name, email: email, phone: String(UUID().uuidString.prefix(20)), password: password, userType: .individual)
        )
        
        guard response.success else {
            throw CreateAccountError.registrationFailed
        }
    }
    
    /// Step 2: Confirm registration with verification code and create session
    public func confirmRegistration(email: String, code: String) async throws {
        let authResponse = try await scope.endpoint.registerConfirm(
            .init(email: email, code: code, deviceInfo: nil)
        )
        
        let createSessionUseCase = CreateSessionUseCase(scope: scope)
        let sessionID = try await createSessionUseCase.execute(from: authResponse)
        try await scope.switchSession(with: sessionID)
    }
}
