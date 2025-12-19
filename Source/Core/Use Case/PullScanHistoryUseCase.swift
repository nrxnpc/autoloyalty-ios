import Foundation
import ScopeGraph

/// Use case for pulling user scan history from API
public struct PullScanHistoryUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        let context = scope.coreDataContext
        let scans = try await scope.endpoint.getUserScans().scans
        try await context.perform {
            scans.forEach { raw in
                ScanItem.createOrUpdate(from: raw, in: context)
            }
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
