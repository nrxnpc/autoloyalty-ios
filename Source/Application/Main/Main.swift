import Combine
import Dependencies
import Foundation

@MainActor
final class Main: ObservableObject {
    @Dependency(\.scope) var scope
    @Dependency(\.endpoint) internal var endpoint
    
    enum State: Equatable {
        case loading
        case authentication
        case session(String)
        case guestSession
    }
    @Published var state: State = .loading
    internal var cancellables: Set<AnyCancellable> = []
}

// MARK: - Session

extension Main {
    func restoreSession() async {
        debugPrint("[DEBUG][Main] Try to restore session.")
        await scope.restoreLastActiveSession()
        subscribeOnSessionUpdates()
    }
    
    func continueAsGuest() async {
        guard await scope.session.isGuest else {
            return
        }
        
        state = .guestSession
        debugPrint("[DEBUG][Main] Continue as guest.")
    }
    
    private func subscribeOnSessionUpdates() {
        scope.$session
            .removeDuplicates()
            .sink { [weak self] session in
                self?.suncWithSessionChanges()
            }
            .store(in: &cancellables)
    }
    
    private func suncWithSessionChanges() {
        Task { @MainActor in
            let isGuest = await scope.session.isGuest
            let sessionID = await scope.session.id
            state = isGuest ? .authentication : .session(sessionID)
            // TODO:
            // scheduleSessionJobs(with: scope.session)
            debugPrint("[DEBUG][Main] Session has been changed.")
        }
    }
}
