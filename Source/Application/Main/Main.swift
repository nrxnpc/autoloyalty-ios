import Combine
import Dependencies
import Foundation
import ScopeGraph

@Observable
@MainActor
final class Main {
    @ObservationIgnored
    @Dependency(\.scope) var scope
    
    @ObservationIgnored
    @Dependency(\.endpoint) internal var endpoint
    
    @ObservationIgnored
    private weak var router: Main.Router?
    
    @ObservationIgnored
    internal var cancellables: Set<AnyCancellable> = []
    
    init(router: Main.Router) {
        self.router = router
    }
    
    enum State: Equatable {
        case loading
        case authentication
        case session(String)
        case guestSession
    }
    var state: State = .loading
}

// MARK: - Session

extension Main {
    func restoreSession() async {
        debugPrint("[DEBUG][Main] Try to restore session.")
        await scope.restoreLastActiveSession()
        subscribeOnSessionUpdates()
        subscribeToSessionHasExpired()
    }
    
    func continueAsGuest() async {
        guard await scope.session.isGuest else {
            return
        }
        
        await scheduleGuestSessionJobs()
        state = .guestSession
        debugPrint("[DEBUG][Main] Continue as guest.")
    }
    
    private func subscribeOnSessionUpdates() {
        scope.sessionPublisher
            .sink { [weak self] session in
                self?.suncWithSessionChanges()
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToSessionHasExpired() {
         scope.onSessionHasExpired
             .receive(on: DispatchQueue.main)
             .sink { [weak self] _ in
                 self?.router?.route(sheet: .reauthenticationView)
             }
             .store(in: &cancellables)
    }
    
    private func suncWithSessionChanges() {
        Task { @MainActor in
            let isGuest = await scope.session.isGuest
            let sessionID = await scope.session.id
            
            if isGuest {
                state = .authentication
            } else {
                state = .session(sessionID)
                Task {
                    await scheduleSessionJobs()
                }
            }
            
            debugPrint("[DEBUG][Main] Session has been changed.")
        }
    }
}
