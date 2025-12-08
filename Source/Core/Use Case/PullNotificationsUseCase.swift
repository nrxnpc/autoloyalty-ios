import Foundation
import ScopeGraph

/// Use case for grab news, notifications, etc.
public struct PullNotificationsUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        let context = scope.coreDataContext
        try await context.perform {
            let message = InboxMessage(context: context)
            message.title = "Welcome to the app!"
            message.subtitle = "You're now logged in!"
            try context.save()
        }
    }
}
