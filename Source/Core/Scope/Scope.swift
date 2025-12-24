import Endpoint
import CoreData
import Combine
import Foundation
import ScopeGraph

// MARK: - Scope

@Observable
public final class Scope: @unchecked Sendable {
    /// Current session - always present (guest or authenticated user)
    public internal(set) var session: AppSessionActor {
        didSet {
            sessionSubject.send(session)
        }
    }
    
    @ObservationIgnored
    private let sessionSubject: CurrentValueSubject<AppSessionActor, Never>
    
    @ObservationIgnored
    public var sessionPublisher: AnyPublisher<AppSessionActor, Never> {
        sessionSubject
            .removeDuplicates { ObjectIdentifier($0) == ObjectIdentifier($1) }
            .eraseToAnyPublisher()
    }
    
    /// Data management pipeline using ScopeGraph
    @ObservationIgnored
    public let dataPipeline: DataPipeline
    
    /// API endpoint for server communication
    @ObservationIgnored
    public let endpoint: RestEndpoint
    
    /// Session management component
    @ObservationIgnored
    internal let sessionComponent: AppSessionComponent
    
    /// Signal for token refresh errors
    public let onSessionHasExpired = PassthroughSubject<Error, Never>()
    
    // MARK: - Initialization
    
    public init(dataPipeline: DataPipeline, apiEndpoint: RestEndpoint) {
        self.dataPipeline = dataPipeline
        self.endpoint = apiEndpoint
        self.sessionComponent = SessionFactory.createSessionComponent()
        let guest = SessionFactory.createGuestSession()
        self.session = guest
        self.sessionSubject = CurrentValueSubject(guest)
        
        Task { await restoreLastActiveSession() }
    }
    
    public convenience init() {
        self.init(
            dataPipeline: Self.createDataPipeline(),
            apiEndpoint: .localhost
        )
    }
    
    // MARK: - Private Factory Methods
    
    private static func createDataPipeline() -> DataPipeline {
        return ScopeGraphKits.userDataKit {
            Scope.Domain.schema.createCoreDataModel()
        }
    }
    
    // MARK: - Public Properties
    
    /// Get CoreData context for task operations
    public var coreDataContext: NSManagedObjectContext {
        dataPipeline.coreDataStack().viewContext
    }
    
    public func createBackgroundContext() -> NSManagedObjectContext {
        dataPipeline.coreDataStack().newBackgroundContext()
    }
    
    /// Check if user is authenticated
    public var isAuthenticated: Bool {
        !session.isGuestSync
    }
    
    /// Get current session info
    public var currentSessionInfo: AppSessionInfo {
        session.infoSync
    }
}
