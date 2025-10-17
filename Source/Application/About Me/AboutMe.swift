import Combine
import Dependencies
import Foundation
import ScopeGraph

@MainActor
final class AboutMe: ObservableObject {
    // MARK: - Dependencies
    
    @Dependency(\.scope) var scope
    
    /// The username (nickname) being edited by the user.
    @Published var username: String = ""
    
    /// The email of the account, which is read-only.
    @Published private(set) var email: String = ""
    
    /// A flag indicating that the ViewModel is waiting for its initial `Account` data.
    /// The view uses this to show a loading indicator.
    @Published private(set) var isUpdating: Bool = true
}

extension AboutMe {
    
}
