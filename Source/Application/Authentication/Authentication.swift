import Dependencies
import Foundation

@MainActor
final class Authentication: ObservableObject {
    @Dependency(\.scope) var scope
    @Dependency(\.endpoint) internal var endpoint
    
    enum UpdatingError: Error { case somethingWentWrong }
    @Published var isUpdating: Bool = false
    
    // MARK: - User Authentication Data
    
    @MainActor final class Input: ObservableObject {
        enum Item: Hashable {
            case email
            case password
        }
        
        @Published var name: String = ""
        @Published var email: String = ""
        @Published var password: String = ""
        @Published var confirmationCode: String = ""
        
        func next(item: inout Item?) {
            guard let current = item else { return }
            switch current {
            case .email: item = .password
            case .password: item = nil
            }
        }
    }
}

extension Authentication {
    @MainActor
    func login(with input: Authentication.Input) async throws {
        isUpdating = true
        defer {
            isUpdating = false
        }
        
        try await LoginUseCase(scope: scope).execute(email: input.email, password: input.password)
    }
    
    @MainActor
    func createAccount(with input: Authentication.Input) async throws {
        isUpdating = true
        defer {
            isUpdating = false
        }
        
        let createAccount = CreateAccountUseCase(scope: scope)
        try await createAccount.execute(email: input.email, password: input.password, confirmationCode: "")
    }
}

extension Authentication.UpdatingError {
    var message: String {
        switch self {
        case .somethingWentWrong: "Ups! Something went wrong while logging in. Try again later."
        }
    }
}
