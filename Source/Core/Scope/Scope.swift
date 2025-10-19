import Endpoint
import CoreData
import Foundation
import ScopeGraph

// MARK: - Scope
public final class Scope: ObservableObject, @unchecked Sendable {
    /// Current session - always present (guest or authenticated user)
    @Published public internal(set) var session: AppSessionActor
    
    /// Data management pipeline using ScopeGraph
    public let dataPipeline: DataPipeline
    
    /// API endpoint for server communication
    public let endpoint: RestEndpoint
    
    /// Session management component
    internal let sessionComponent: AppSessionComponent
    
    // MARK: - Initialization
    
    public init(dataPipeline: DataPipeline, apiEndpoint: RestEndpoint) {
        self.dataPipeline = dataPipeline
        self.endpoint = apiEndpoint
        self.sessionComponent = SessionFactory.createSessionComponent()
        self.session = SessionFactory.createGuestSession()
        
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
    
    /// Check if user is authenticated
    public var isAuthenticated: Bool {
        !session.isGuestSync
    }
    
    /// Get current session info
    public var currentSessionInfo: AppSessionInfo {
        session.infoSync
    }
}
