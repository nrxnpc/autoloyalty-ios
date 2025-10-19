import Foundation
import CoreData

/// Account domain entity with CoreData support
@objc(Account)
public class Account: Entity {
    @NSManaged public var name: String
    @NSManaged public var email: String
    @NSManaged public var phone: String?
    @NSManaged public var points: Int
    @NSManaged public var image: Attachment
}

// MARK: - Convenience Properties

public extension Account {
    /// Whether account is a ghost account (special guest mode account)
    var isGuest: Bool {
        id == "guest"
    }
    
    static func createGuestAccount(in context: NSManagedObjectContext) throws {
        let account = try Account.byID("guest").execute().first ?? Account.create(id: "guest", in: context)
        account.name = "Demo Customer"
        account.email = "customer@email.com"
        account.points = 8633
        if context.hasChanges {
            try context.save()
        }
    }
}
