@preconcurrency import CoreData
import Combine
import Dependencies
import ScopeGraph

@MainActor
final class BalanceMonitor: ObservableObject {
    // MARK: - Dependencies
    
    @Dependency(\.scope) var scope
    
    // MARK: -
    
    @Published var balance: Int = 0
    
    // MARK: -
    
    private var account: FetchedObject<Account>!
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        let currentAccount = scope.currentSessionInfo.accountID
        account = .init(Account.byID(currentAccount))
        account.startObserving(context: scope.coreDataContext)
        account
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] account in
                if let balance = account?.points {
                    self?.balance = balance
                }
            }
            .store(in: &cancellables)
    }
}
