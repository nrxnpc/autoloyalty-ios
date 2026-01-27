import Dependencies
import Foundation
import ScopeGraph

public struct PullSupportMessagesUseCase {
    @Dependency(\.scope) var scope
    
    private let router: Main.Router?
    init(router: Main.Router?) {
        self.router = router
    }
    
    public func execute() async throws {
        let context = scope.createBackgroundContext()
        let accountID = scope.currentSessionInfo.sessionID
        
        let lastMessageDate: Date? = try await context.perform {
            try context.fetch(SupportMessage.lastMessage()).first?.createdAt
        }
        
        let since: String? = lastMessageDate.map {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter.string(from: $0)
        }
        
        let request = RestEndpoint.SupportMessagesRequest(since: since)
        let response = try await scope.endpoint.getSupportMessages(request)
        
        var hasNewIncomingMessages = false
        try await context.perform {
            response.messages.forEach { raw in
                SupportMessage.createOrUpdate(from: raw, isOwned: raw.senderId == accountID, in: context)
                if raw.senderId != accountID {
                    hasNewIncomingMessages = true
                }
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
        
        let isContactSupportOpen = await router?.isContactSupportOpen ?? true
        if !isContactSupportOpen && hasNewIncomingMessages {
            try await createInboxNotification()
        }
        
        try await sanitize()
    }
    
    private func createInboxNotification() async throws {
        let context = scope.createBackgroundContext()
        
        try await context.perform {
            let hasNoUnreadMessagesFromSupport = try context.fetch(InboxMessage.unreadSupportMessages()).isEmpty
            if hasNoUnreadMessagesFromSupport {
                InboxMessage.createSupportNotification(in: context)
                if context.hasChanges {
                    try context.save()
                }
            }
        }
    }
    
    private func sanitize() async throws {
        let context = scope.createBackgroundContext()
        
        try await context.perform {
            let messages = try context.fetch(InboxMessage.readSupportMessagesOlderThan(hours: 24))
            messages.forEach { context.delete($0) }
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
