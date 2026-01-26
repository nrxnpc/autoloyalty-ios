import Dependencies
import Foundation
import ScopeGraph

public struct PullSupportMessagesUseCase {
    @Dependency(\.scope) var scope
    
    public func execute() async throws {
        let context = scope.createBackgroundContext()
        let accountID = scope.currentSessionInfo.accountID
        
        let lastMessageDate: Date? = try await context.perform {
            try context.fetch(SupportMessage.lastMessage()).first?.createdAt
        }
        
        let since = lastMessageDate.map { ISO8601DateFormatter().string(from: $0) }
        let request = RestEndpoint.SupportMessagesRequest(since: since)
        let response = try await scope.endpoint.getSupportMessages(request)
        
        try await context.perform {
            response.messages.forEach { raw in
                SupportMessage.createOrUpdate(from: raw, isOwned: raw.senderId == accountID, in: context)
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
