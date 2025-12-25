import Foundation
import ScopeGraph

public struct ScanQRUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    enum ScanQRError: Error {
        case wasUsed, notFound
    }
    
    public func execute(value: String) async throws -> Int {
        debugPrint("[DEBUG][Scan] Starting QR scan for value: \(value)")
        let context = scope.createBackgroundContext()
        
        do {
            let scan = try await scope.endpoint.scanQRCode(.init(qrCode: value))
            debugPrint("[DEBUG][Scan] API response received: pointsEarned=\(scan.pointsEarned ?? 0), usedAt=\(scan.usedAt?.description ?? "nil")")
            
            if scan.usedAt != nil {
                throw ScanQRError.wasUsed
            }
            
            if let income = scan.pointsEarned, income > 0 {
                let accountID = scope.currentSessionInfo.accountID
                debugPrint("[DEBUG][Scan] Updating account: \(accountID)")
                
                try await context.perform {
                    let request = Account.byID(accountID)
                    guard let account = try context.fetch(request).first else {
                        return
                    }
                    
                    account.points += income
                    if context.hasChanges {
                        try context.save()
                    }
                }
                
                // TODO: Calc total account from history
                // do {
                //     try await PullUserTransactionsUseCase(scope: scope).execute()
                // } catch {
                //     debugPrint("[DEBUG][Scan] Can't pull transactions after earning points")
                // }
                
                return income
            }
            
            throw ScanQRError.notFound
        } catch {
            debugPrint("[DEBUG][Scan] Error occurred: \(error)")
            
            let errorDescription = error.localizedDescription
            if errorDescription.contains("409") || errorDescription.contains("already used") {
                debugPrint("[DEBUG][Scan] HTTP 409 - QR code already used")
                throw ScanQRError.wasUsed
            }
            
            throw error
        }
    }
}
