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
        
        let firstMessage = try await context.perform {
            let messages = try context.fetch(SupportMessage.allDrafts())
            return messages.count == 0
        }
        
        guard firstMessage else {
            return
        }
        try await Task.sleep(for: .seconds(1))
        
        try await context.perform {
            let supportMessage = SupportMessage(context: context)
            supportMessage.sync.isDraft = true
            supportMessage.text = """
                Service Unavailable 🛠️ 
                
                We’re undergoing technical maintenance and will be back as soon as possible. Sorry for the inconvenience!
                
                If you need urgent help, please contact us via email. ✉️
                """
            supportMessage.isOwned = false
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
