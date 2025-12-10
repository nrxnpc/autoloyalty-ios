@preconcurrency import CoreData
import Combine
import Dependencies
import ScopeGraph

@MainActor
final class InboxMonitor: ObservableObject {
    @Dependency(\.scope) var scope
    
    @Published var unreadCount: Int = 0
    
    private var unreadMessages: FetchedObjects<InboxMessage> = .init(InboxMessage.unreadMessages())
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        unreadMessages.startObserving(context: scope.coreDataContext)
        unreadMessages
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                self?.unreadCount = messages.count
            }
            .store(in: &cancellables)
    }
}
