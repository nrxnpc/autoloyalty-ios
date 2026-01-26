import Dependencies
import Foundation
import ScopeGraph

public struct PushSupportMessagesUseCase {
    @Dependency(\.scope) var scope
    
    public func execute() async throws {
        let context = scope.createBackgroundContext()
        
        let unsynced = try await context.perform {
            try context.fetch(SupportMessage.allUnsynced())
        }
        
        for message in unsynced {
            let messageID = message.objectID
            let text = message.text
            let request = RestEndpoint.SupportMessageRequest(content: text)
            let response = try await scope.endpoint.sendSupportMessage(request)
            
            try await context.perform {
                guard let message = try? context.existingObject(with: messageID) as? SupportMessage else { return }
                message.sync.externalID = response.message?.id
                
                if context.hasChanges {
                    try context.save()
                }
            }
        }
    }
}
