import Foundation
import ScopeGraph

/// Use case for create welcome notificaiton
public struct CreateWelcomeMessageUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        let context = scope.createBackgroundContext()
        let messages = try context.fetch(InboxMessage.allMessagesSortedByCreatedDate())
        guard messages.isEmpty else {
            return
        }
        
        try await context.perform {
            let message = InboxMessage(context: context)
            message.title = "Welcome to the app!"
            // See localizable string
            message.subtitle = "Thank you for joining the NSP Group loyalty program for automotive parts!"
            try context.save()
        }
    }
}
