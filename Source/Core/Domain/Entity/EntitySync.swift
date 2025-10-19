import Foundation
import CoreData

/// Entity synchronization record for server sync management
@objc(EntitySync)
public class EntitySync: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var isDraft: Bool
    @NSManaged public var externalID: String?
    @NSManaged public var updatedAt: Date
    @NSManaged public var entityReference: Entity
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        if id.isEmpty {
            id = UUID().uuidString
        }
        isDraft = false
        updatedAt = Date()
    }
}

// MARK: - Sync Status

public extension EntitySync {
    /// Whether entity is synced to server
    var isSynced: Bool { externalID != nil }
    
    /// Whether entity exists only locally
    var isLocalOnly: Bool { externalID == nil }
}
