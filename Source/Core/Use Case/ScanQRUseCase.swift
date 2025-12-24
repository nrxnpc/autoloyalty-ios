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
        let context = scope.createBackgroundContext()
        let scan = try await scope.endpoint.scanQRCode(.init(qrCode: value))
        
        if let income = scan.pointsEarned, income > 0 {
            let accountID = scope.currentSessionInfo.accountID
            try await context.perform {
                let request = Account.byID(accountID)
                guard let account = try context.fetch(request).first else {
                    return
                }
                account.points += income
                try context.save()
            }
            return income
        }
        
        if scan.usedAt != nil {
            throw ScanQRError.wasUsed
        }
        
        throw ScanQRError.notFound
    }
}
