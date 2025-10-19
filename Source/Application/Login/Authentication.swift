import Dependencies
import Foundation

@MainActor
final class Authentication: ObservableObject {
    @Dependency(\.scope) var scope
    @Dependency(\.endpoint) internal var endpoint
    
    enum UpdatingError: Error { case somethingWentWrong }
    @Published var isUpdating: Bool = false
}

extension Authentication {
    @MainActor
    func login(with input: LoginView.Input) async throws {
        isUpdating = true
        defer {
            isUpdating = false
        }
        
        try await scope.grab { [endpoint] in
            try await endpoint.login(.init(email: input.email, password: input.password))
        }
    }
    
    @MainActor
    func createAccount(with input: CreateAccountView.Input) async throws {
        isUpdating = true
        defer {
            isUpdating = false
        }
        
         try await scope.grab { [endpoint] in
             try await endpoint.register(.init(name: input.name, email: input.email, phone: UUID().uuidString, password: input.password, userType: input.isCompany ? .company : .individual))
         }
    }
}

extension Authentication.UpdatingError {
    var message: String {
        switch self {
        case .somethingWentWrong: "Ups! Something went wrong while logging in. Try again later."
        }
    }
}
