import Dependencies
import Foundation
import ScopeGraph

public struct SendMessageToSupportUseCase {
    @Dependency(\.scope) var scope
    
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
    }
}
