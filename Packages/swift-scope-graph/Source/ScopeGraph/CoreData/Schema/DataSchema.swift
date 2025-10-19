import Foundation
import CoreData

// MARK: - Data Schema DSL

/// A declarative DSL for defining a Core Data schema.
public struct DataSchema {
    private let entities: [EntityDefinition]
    
    public init(@EntityDescriptionBuilder _ builder: () -> [EntityDefinition]) {
        self.entities = builder()
    }
    
    /// Converts the high-level DSL schema into a fully configured `NSManagedObjectModel`.
    ///
    /// This function uses a robust multi-pass approach to avoid memory corruption issues (`EXC_BAD_ACCESS`)
    /// when building complex models with inheritance and inverse relationships.
    ///
    /// The process is as follows:
    /// 1. Create all `NSEntityDescription` objects with their immediate properties.
    /// 2. Establish the inheritance hierarchy by configuring the `subentities` array on parent entities.
    /// 3. **Pass 1:** Configure all relationships by setting their `destinationEntity`.
    /// 4. **Pass 2:** Configure all `inverseRelationship` properties now that the model graph is stable.
    ///
    /// - Returns: A compiled and consistent `NSManagedObjectModel`.
    public func createCoreDataModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // --- Step 1: Create all entity descriptions from the DSL schemas ---
        let entityDescriptions = entities.map { $0.toEntityDescription() }
        let entitiesByName: [String: NSEntityDescription] = Dictionary(uniqueKeysWithValues: entityDescriptions.compactMap { entity in
            guard let name = entity.name else { return nil }
            return (name, entity)
        })
        
        // --- Step 2: Establish the inheritance hierarchy ---
        for schemaDefinition in entities {
            guard let entitySchema = schemaDefinition as? EntitySchema,
                  let parentName = entitySchema.inherits else {
                continue
            }
            
            if let childEntity = entitiesByName[entitySchema.name],
               let parentEntity = entitiesByName[parentName] {
                // To modify the `subentities` array (a value type), we must get a mutable copy,
                // modify it, and then assign it back to the property.
                var parentSubentities = parentEntity.subentities
                parentSubentities.append(childEntity)
                parentEntity.subentities = parentSubentities
            } else {
                print("⚠️ [Schema Warning] Parent entity '\(parentName)' defined for '\(entitySchema.name)' was not found.")
            }
        }
        
        // --- Step 3: Configure Relationships (Pass 1 - Set Destination Entities) ---
        // In this pass, we only link relationships to their destination types. We do not
        // configure the inverse yet, ensuring the graph of entities is fully connected first.
        for entity in entityDescriptions {
            for property in entity.properties {
                if let relationship = property as? NSRelationshipDescription {
                    // Note: `entity.properties` includes inherited properties.
                    if let sourceEntitySchema = findSchema(for: entity),
                       let relationshipDef = findRelationshipDefinition(in: sourceEntitySchema, named: relationship.name) {
                        relationship.destinationEntity = entitiesByName[relationshipDef.destinationEntity]
                    }
                }
            }
        }
        
        // --- Step 4: Configure Relationships (Pass 2 - Set Inverse Relationships) ---
        // Now that all destinations and inheritance are set, it is safe to set the
        // inverse relationships. Core Data can now safely traverse the model graph.
        for entity in entityDescriptions {
            for property in entity.properties {
                if let relationship = property as? NSRelationshipDescription {
                    if let sourceEntitySchema = findSchema(for: entity),
                       let relationshipDef = findRelationshipDefinition(in: sourceEntitySchema, named: relationship.name),
                       let inverseName = relationshipDef.inverse,
                       let destinationEntity = relationship.destinationEntity,
                       let inverseRelationship = destinationEntity.relationshipsByName[inverseName] {
                        
                        // Set the inverse on both sides of the relationship for maximum safety and consistency.
                        relationship.inverseRelationship = inverseRelationship
                        inverseRelationship.inverseRelationship = relationship
                    }
                }
            }
        }
        
        model.entities = entityDescriptions
        return model
    }
    
    /// Helper function to find the original DSL `EntitySchema` for a given `NSEntityDescription`.
    private func findSchema(for entity: NSEntityDescription) -> EntitySchema? {
        guard let entityName = entity.name else { return nil }
        return entities.first { ($0 as? EntitySchema)?.name == entityName } as? EntitySchema
    }
    
    /// Finds a `Relationship` definition by recursively searching the entity's own fields and its parents' fields.
    /// This is necessary because `NSEntityDescription.properties` includes inherited properties.
    private func findRelationshipDefinition(in entity: EntitySchema, named relationshipName: String) -> Relationship? {
        let allFields = entity.fields + getInheritedFields(from: entity.inherits)
        return allFields.compactMap { $0 as? Relationship }.first { $0.name == relationshipName }
    }
    
    /// Recursively gathers all `FieldDefinition` objects from an entity and all of its ancestors.
    private func getInheritedFields(from parentName: String?) -> [FieldDefinition] {
        guard let parentName = parentName else { return [] }
        
        if let parentEntity = entities.first(where: { ($0 as? EntitySchema)?.name == parentName }) as? EntitySchema {
            return parentEntity.fields + getInheritedFields(from: parentEntity.inherits)
        }
        return []
    }
}

// MARK: - DSL Component Definitions

/// A definition for a data model entity.
public struct EntitySchema {
    let name: String
    let inherits: String?
    let fields: [FieldDefinition]
    
    public init(_ name: String, inherits: String? = nil, @FieldBuilder _ builder: () -> [FieldDefinition]) {
        self.name = name
        self.inherits = inherits
        self.fields = builder()
    }
}

/// A definition for a standard attribute field.
public struct Field {
    let name: String
    let type: FieldType
    let optional: Bool
    let defaultValue: Any?
    
    public init(_ name: String, _ type: FieldType, optional: Bool = false, default defaultValue: Any? = nil) {
        self.name = name
        self.type = type
        self.optional = optional
        self.defaultValue = defaultValue
    }
}

/// A definition for a value object.
public struct ValueObject {
    let name: String
    let type: Any.Type
    
    public init<T>(_ name: String, type: T.Type) {
        self.name = name
        self.type = type
    }
}

/// A definition for a relationship between entities.
public struct Relationship {
    let name: String
    let destinationEntity: String
    let optional: Bool
    let inverse: String?
    let deleteRule: NSDeleteRule
    
    public init(_ name: String, to destinationEntity: String, optional: Bool = false, deleteRule: NSDeleteRule = .nullifyDeleteRule) {
        self.name = name
        self.destinationEntity = destinationEntity
        self.optional = optional
        self.inverse = nil
        self.deleteRule = deleteRule
    }
    
    public init(_ name: String, to destinationEntity: String, inverse: String, optional: Bool = false, deleteRule: NSDeleteRule = .nullifyDeleteRule) {
        self.name = name
        self.destinationEntity = destinationEntity
        self.optional = optional
        self.inverse = inverse
        self.deleteRule = deleteRule
    }
}

/// Supported attribute types for entity fields.
public enum FieldType {
    case identifier, text, boolean, timestamp, number, data, url
}

/// A definition for a field that allows external storage for large binary data.
public struct ExternalDataField {
    let name: String
    let optional: Bool
    
    public init(_ name: String, optional: Bool = false) {
        self.name = name
        self.optional = optional
    }
}

/// A definition for a transformable attribute using a custom `ValueTransformer`.
public struct TransformableField {
    let name: String
    let transformer: String
    let customClass: String
    let optional: Bool
    
    public init(_ name: String, transformer: String, customClass: String, optional: Bool = false) {
        self.name = name
        self.transformer = transformer
        self.customClass = customClass
        self.optional = optional
    }
}

// MARK: - Result Builders

@resultBuilder
public struct EntityDescriptionBuilder {
    public static func buildBlock(_ entities: EntityDefinition...) -> [EntityDefinition] {
        return entities
    }
}

@resultBuilder
public struct FieldBuilder {
    public static func buildBlock(_ fields: FieldDefinition...) -> [FieldDefinition] {
        return fields
    }
    
    public static func buildBlock(_ fields: [FieldDefinition]) -> [FieldDefinition] {
        return fields
    }
}

// MARK: - Protocol Definitions

public protocol EntityDefinition {
    func toEntityDescription() -> NSEntityDescription
}

public protocol FieldDefinition {
    func toPropertyDescription() -> NSPropertyDescription
}

// MARK: - CoreData Conversion Extensions

extension EntitySchema: EntityDefinition {
    public func toEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = name
        entity.managedObjectClassName = name
        entity.properties = fields.map { $0.toPropertyDescription() }
        return entity
    }
}

extension Field: FieldDefinition {
    public func toPropertyDescription() -> NSPropertyDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.isOptional = optional
        
        switch type {
        case .identifier, .text: attribute.attributeType = .stringAttributeType
        case .boolean:          attribute.attributeType = .booleanAttributeType
        case .timestamp:        attribute.attributeType = .dateAttributeType
        case .number:           attribute.attributeType = .integer64AttributeType
        case .data:             attribute.attributeType = .binaryDataAttributeType
        case .url:              attribute.attributeType = .URIAttributeType
        }
        
        if let defaultValue = defaultValue {
            attribute.defaultValue = defaultValue
        }
        
        return attribute
    }
}

extension ValueObject: FieldDefinition {
    public func toPropertyDescription() -> NSPropertyDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "\(name)Data"
        attribute.attributeType = .binaryDataAttributeType
        attribute.isOptional = true
        return attribute
    }
}

extension Relationship: FieldDefinition {
    public func toPropertyDescription() -> NSPropertyDescription {
        let relationship = NSRelationshipDescription()
        relationship.name = name
        relationship.isOptional = optional
        relationship.maxCount = 1 // Defines a to-one relationship
        relationship.deleteRule = deleteRule
        return relationship
    }
}

extension ExternalDataField: FieldDefinition {
    public func toPropertyDescription() -> NSPropertyDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .binaryDataAttributeType
        attribute.isOptional = optional
        attribute.allowsExternalBinaryDataStorage = true
        return attribute
    }
}

extension TransformableField: FieldDefinition {
    public func toPropertyDescription() -> NSPropertyDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .transformableAttributeType
        attribute.isOptional = optional
        attribute.valueTransformerName = transformer
        attribute.attributeValueClassName = customClass
        return attribute
    }
}
