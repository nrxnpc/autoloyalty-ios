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
            message.subtitle = """
                    Thank you for joining the NSP Group loyalty program for automotive parts!

                    🎯 How it works:
                    • Scan QR codes on NSP parts packaging
                    • Earn loyalty points for each scan
                    • Redeem points for exclusive rewards in our catalog

                    📈 Growing benefits:
                    Our catalog will continuously expand with new rewards and exclusive offers. Your accumulated points will become even more valuable as we add premium gifts and special deals. Stay with us and watch your benefits grow.

                    Good luck from the Development Team! 🚀
                    """
            try context.save()
        }
    }
}
