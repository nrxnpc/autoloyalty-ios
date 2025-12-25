import Foundation
import ScopeGraph

/// Use case for pulling user scan history from API
public struct PullScanHistoryUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        debugPrint("[DEBUG][PullScanHistory] Starting scan history pull")
        let context = scope.createBackgroundContext()
        let scans = try await scope.endpoint.getUserScans().scans
        debugPrint("[DEBUG][PullScanHistory] Received \(scans.count) scans")
        try await context.perform {
            scans.forEach { raw in
                ScanItem.createOrUpdate(from: raw, in: context)
            }
            if context.hasChanges {
                try context.save()
                debugPrint("[DEBUG][PullScanHistory] Database saved successfully")
            }
        }
    }
}
