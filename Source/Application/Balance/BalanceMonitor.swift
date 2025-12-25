@preconcurrency import CoreData
import Combine
import Dependencies
import ScopeGraph

@Observable
@MainActor
final class BalanceMonitor {
    // MARK: - Dependencies
    
    @ObservationIgnored
    @Dependency(\.scope) var scope
    
    // MARK: -
    
    var balance: Int = 0
    
    // MARK: -
    
    @ObservationIgnored
    private var account: FetchedObject<Account>!
    
    @ObservationIgnored
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        let currentAccount = scope.currentSessionInfo.accountID
        account = .init(Account.byID(currentAccount))
        account.startObserving(context: scope.coreDataContext)
        account
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] account in
                Task { @MainActor in
                    if let balance = account?.points {
                        self?.balance = balance
                    }
                }
            }
            .store(in: &cancellables)
    }
}
