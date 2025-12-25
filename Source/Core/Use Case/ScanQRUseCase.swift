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
            
            if let income = scan.pointsEarned, income > 0 {
                let accountID = scope.currentSessionInfo.accountID
                debugPrint("[DEBUG][Scan] Updating account: \(accountID)")
                
                try await context.perform {
                    let request = Account.byID(accountID)
                    guard let account = try context.fetch(request).first else {
                        return
                    }
                    let oldPoints = account.points
                    account.points += income
                    try context.save()
                }
                return income
            }
            
            if scan.usedAt != nil {
                throw ScanQRError.wasUsed
            }
            
            debugPrint("[DEBUG][Scan] QR code not found or invalid")
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
