import Foundation
import CoreData

/// Builder for creating CoreData models programmatically
public class CoreDataModelBuilder {
    private var entities: [NSEntityDescription] = []
    
    public init() {}
    
    /// Add entity to the model
    public func addEntity(_ name: String, className: String? = nil, configure: (EntityBuilder) -> Void) -> Self {
        let entityBuilder = EntityBuilder(name: name, className: className)
        configure(entityBuilder)
        entities.append(entityBuilder.build())
        return self
    }
    
    /// Build the complete NSManagedObjectModel
    public func build() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = entities
        return model
    }
}

/// Builder for individual entities
public class EntityBuilder {
    private let entity: NSEntityDescription
    private var attributes: [NSAttributeDescription] = []
    private var relationships: [NSRelationshipDescription] = []
    
    init(name: String, className: String?) {
        entity = NSEntityDescription()
        entity.name = name
        entity.managedObjectClassName = className ?? name
    }
    
    /// Add string attribute
    public func stringAttribute(_ name: String, optional: Bool = true) -> Self {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = optional
        attributes.append(attribute)
        return self
    }
    
    /// Add boolean attribute
    public func boolAttribute(_ name: String, optional: Bool = false) -> Self {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .booleanAttributeType
        attribute.isOptional = optional
        attributes.append(attribute)
        return self
    }
    
    /// Add date attribute
    public func dateAttribute(_ name: String, optional: Bool = true) -> Self {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .dateAttributeType
        attribute.isOptional = optional
        attributes.append(attribute)
        return self
    }
    
    /// Add transformable attribute for complex types
    public func transformableAttribute(_ name: String, optional: Bool = true) -> Self {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .transformableAttributeType
        attribute.isOptional = optional
        attributes.append(attribute)
        return self
    }
    
    /// Build the entity
    func build() -> NSEntityDescription {
        entity.properties = attributes + relationships
        return entity
    }
}