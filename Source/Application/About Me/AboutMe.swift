import Combine
import Dependencies
import Foundation
import ScopeGraph

@MainActor
final class AboutMe: ObservableObject {
    // MARK: - Dependencies
    
    @Dependency(\.scope) var scope
    
    @Published private(set) var accountID: String = ""
    
    /// The username (nickname) being edited by the user.
    @Published var username: String = ""
    
    /// The email of the account, which is read-only.
    @Published private(set) var email: String = ""
    
    /// A flag indicating that the ViewModel is waiting for its initial `Account` data.
    /// The view uses this to show a loading indicator.
    @Published private(set) var isUpdating: Bool = true
    
    /// The internal observer for the `Account` entity in Core Data.
    @Published private(set) var account: FetchedObject<Account>?
    
    private var cancellables = Set<AnyCancellable>()
    private var accountFetcherCancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Initializes the profile manager for a specific account ID.
    ///
    /// It sets up the data fetcher, subscribes to its updates, and immediately starts
    /// observing Core Data using the context from the application's dependency scope.
    /// - Parameter accountID: The ID of the `Account` to manage.
    init() {
        subscribeOnSessionUpdates()
    }
}

// MARK: - Subscriprions

extension AboutMe {
    private func subscribeOnSessionUpdates() {
        scope.$session
            .removeDuplicates()
            .sink { [weak self] _ in self?.updateSession() }
            .store(in: &cancellables)
    }
    
    private func updateSession() {
        Task { @MainActor in
            accountID = await scope.session.info.accountID
            account = FetchedObject(Account.byID(accountID), context: scope.coreDataContext)
            subscribeOnAccountFetcherUpdates()
        }
    }
    
    private func subscribeOnAccountFetcherUpdates() {
        guard let account else {
            return
        }
        
        accountFetcherCancellables.removeAll()
        
        // Subscribe to changes from the account fetcher.
        // Whenever the account in Core Data changes, the `sync` method will be called.
        account.sink { [weak self] account in
            self?.updatePublished(with: account)
        }
        .store(in: &accountFetcherCancellables)
    }
    
    /// Synchronizes the ViewModel's state with an `Account` object from Core Data.
    ///
    /// This method is called automatically whenever the fetched `Account` becomes available
    /// or changes. It resets the editing state to reflect the latest data from the database.
    /// - Parameter account: The latest `Account` object from the database, or `nil` if not found.
    private func updatePublished(with account: Account?) {
        guard let account = account else {
            // If the account is nil, we keep `isUpdating` true, so the view
            // continues to show a loading state until an account is created.
            return
        }
        
        // View Data:
        self.username = account.nickname
        self.email = account.email
        
        // Mark the initial update as complete.
        if isUpdating {
            self.isUpdating = false
        }
        debugPrint("[Debug][AccountProfile] Publishers updated")
    }
}
