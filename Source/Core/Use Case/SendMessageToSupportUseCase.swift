import Dependencies
import Foundation
import ScopeGraph

public struct SendMessageToSupportUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func send(text: String) async throws {
        let context = scope.createBackgroundContext()
        
        try await context.perform {
            let supportMessage = SupportMessage(context: context)
            supportMessage.text = text
            supportMessage.isOwned = true
            
            if context.hasChanges {
                try context.save()
            }
        }
        try await Task.sleep(for: .seconds(1))
        
        try await context.perform {
            let messages = try context.fetch(SupportMessage.allDrafts())
            guard messages.count == 0 else {
                return
            }
            
            let supportMessage = SupportMessage(context: context)
            supportMessage.text = """
                Our service is temporarily unavailable due to technical reasons. We are currently working on resolving the issue and will be back online as soon as possible.
                If you have an urgent matter, you can contact us via e-mail: support@nsp-app.ru
                We apologize for any inconvenience this may cause.
                """
            supportMessage.isOwned = false
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
