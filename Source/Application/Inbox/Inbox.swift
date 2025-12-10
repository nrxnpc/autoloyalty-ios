import Dependencies
import Foundation
import CoreData

@MainActor
final class Inbox: ObservableObject {
    @Dependency(\.scope) var scope
    
    func markAllAsRead() {
        let context = scope.coreDataContext
        let request = InboxMessage.unreadMessages()
        if let messages = try? context.fetch(request) {
            messages.forEach { $0.wasReaded = true }
            try? context.save()
        }
    }
}
