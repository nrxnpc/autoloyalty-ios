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
}

extension Authentication.UpdatingError {
    var message: String {
        switch self {
        case .somethingWentWrong: "Ups! Something went wrong while logging in. Try again later."
        }
    }
}
