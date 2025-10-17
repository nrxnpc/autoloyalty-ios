import Foundation
import CoreData

/// Account domain entity with CoreData support
@objc(Account)
public class Account: Entity {
    @NSManaged public var nickname: String
    @NSManaged public var email: String
}

// MARK: - Convenience Properties

public extension Account {
    /// Whether account is a ghost account (special guest mode account)
    var isGuest: Bool {
        id == "guest"
    }
}
