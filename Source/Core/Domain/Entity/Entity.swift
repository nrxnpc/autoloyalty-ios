import Foundation
import CoreData

/// Base entity for all domain objects with CoreData support
@objc(Entity)
public class Entity: NSManagedObject, Identifiable {
    public typealias ID = String
    
    @NSManaged public var id: ID
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var deletedAt: Date?
    @NSManaged public var sync: EntitySync
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        let now = Date()
        if id.isEmpty {
            id = UUID().uuidString
        }
        createdAt = now
        updatedAt = now
        sync = EntitySync(context: self.managedObjectContext!)
    }
    
    public override func willSave() {
        super.willSave()
        
        // Update timestamps
        if !isDeleted && !isInserted {
            let changes = changedValues()
            if !changes.isEmpty && changes["updatedAt"] == nil {
                updatedAt = Date()
            }
        }
    }
}

/// Protocol for domain entities
public protocol DomainEntity: AnyObject {
    var id: String { get }
    var externalID: String? { get }
    var createdAt: Date { get }
    var updatedAt: Date { get }
    var deletedAt: Date? { get }
    var isDeleted: Bool { get }
    var isLocalOnly: Bool { get }
}

// MARK: - Sync Support

extension Entity: DomainEntity {
    /// Whether entity exists only locally (not synced to server)
    public var isLocalOnly: Bool { sync.isLocalOnly }
    
    /// External ID from sync record
    public var externalID: String? { sync.externalID }
    
    public override var isDeleted: Bool { deletedAt != nil }
}

public extension Entity {
    
    /// Создает новый экземпляр Entity вместе с его обязательным EntitySync объектом.
    /// - Parameter context: Контекст управляемого объекта, в который нужно вставить новый объект.
    /// - Returns: Полностью сконфигурированный экземпляр Entity.
    static func insertNewEntity(in context: NSManagedObjectContext) -> Entity {
        let entity = Entity(context: context)
        
        // Создаем и сразу же связываем EntitySync
        let entitySync = EntitySync(context: context)
        // Присваивание в одну сторону автоматически устанавливает обратную связь
        entity.sync = entitySync
        
        return entity
    }
}
