import Dependencies
import Foundation
import CoreData

@Observable
@MainActor
final class ContactSupport {
    @ObservationIgnored
    @Dependency(\.scope) var scope
    
    func markInboxMessagesAsReadIfNeeded() async {
        let context = scope.coreDataContext
        try? await context.perform {
            let messages = try context.fetch(InboxMessage.unreadSupportMessages())
            messages.forEach {
                $0.wasReaded = true
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
