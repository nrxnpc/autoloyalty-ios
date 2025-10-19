import Foundation
import CoreData

// MARK: - Schema Validation

/// Validates schema definitions for consistency and correctness
public struct SchemaValidator {
    
    /// Validates a complete data schema
    public static func validate(_ schema: DataSchema) throws {
        let model = schema.createCoreDataModel()
        try validateEntityRelationships(in: model)
        try validateFieldTypes(in: model)
    }
    
    private static func validateEntityRelationships(in model: NSManagedObjectModel) throws {
        for entity in model.entities {
            for property in entity.properties {
                if let relationship = property as? NSRelationshipDescription {
                    guard model.entities.contains(where: { $0.name == relationship.destinationEntity?.name }) else {
                        throw SchemaValidationError.invalidRelationship(
                            entity: entity.name ?? "Unknown",
                            relationship: relationship.name,
                            destination: relationship.destinationEntity?.name ?? "Unknown"
                        )
                    }
                }
            }
        }
    }
    
    private static func validateFieldTypes(in model: NSManagedObjectModel) throws {
        for entity in model.entities {
            for property in entity.properties {
                if let attribute = property as? NSAttributeDescription {
                    guard attribute.attributeType != .undefinedAttributeType else {
                        throw SchemaValidationError.invalidFieldType(
                            entity: entity.name ?? "Unknown",
                            field: attribute.name
                        )
                    }
                }
            }
        }
    }
}

/// Schema validation errors
public enum SchemaValidationError: Error, LocalizedError {
    case invalidRelationship(entity: String, relationship: String, destination: String)
    case invalidFieldType(entity: String, field: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidRelationship(let entity, let relationship, let destination):
            return "Invalid relationship '\(relationship)' in entity '\(entity)' pointing to unknown entity '\(destination)'"
        case .invalidFieldType(let entity, let field):
            return "Invalid field type for '\(field)' in entity '\(entity)'"
        }
    }
}

// MARK: - Schema Introspection

/// Provides introspection capabilities for schema definitions
public struct SchemaIntrospector {
    
    /// Gets all entity names in a schema
    public static func entityNames(in schema: DataSchema) -> [String] {
        let model = schema.createCoreDataModel()
        return model.entities.compactMap { $0.name }
    }
    
    /// Gets all field names for a specific entity
    public static func fieldNames(for entityName: String, in schema: DataSchema) -> [String] {
        let model = schema.createCoreDataModel()
        guard let entity = model.entities.first(where: { $0.name == entityName }) else {
            return []
        }
        return entity.properties.map { $0.name }
    }
    
    /// Gets relationship information for an entity
    public static func relationships(for entityName: String, in schema: DataSchema) -> [RelationshipInfo] {
        let model = schema.createCoreDataModel()
        guard let entity = model.entities.first(where: { $0.name == entityName }) else {
            return []
        }
        
        return entity.properties.compactMap { property in
            guard let relationship = property as? NSRelationshipDescription else { return nil }
            return RelationshipInfo(
                name: relationship.name,
                destinationEntity: relationship.destinationEntity?.name ?? "Unknown",
                isOptional: relationship.isOptional,
                isToMany: relationship.maxCount != 1
            )
        }
    }
}

/// Relationship information structure
public struct RelationshipInfo {
    public let name: String
    public let destinationEntity: String
    public let isOptional: Bool
    public let isToMany: Bool
}

// MARK: - Schema Migration Utilities

/// Utilities for schema migration and versioning
public struct SchemaMigrationUtilities {
    
    /// Compares two schemas and identifies differences
    public static func diff(from oldSchema: DataSchema, to newSchema: DataSchema) -> SchemaDiff {
        let oldModel = oldSchema.createCoreDataModel()
        let newModel = newSchema.createCoreDataModel()
        
        let oldEntities = Set(oldModel.entities.compactMap { $0.name })
        let newEntities = Set(newModel.entities.compactMap { $0.name })
        
        return SchemaDiff(
            addedEntities: Array(newEntities.subtracting(oldEntities)),
            removedEntities: Array(oldEntities.subtracting(newEntities)),
            modifiedEntities: Array(oldEntities.intersection(newEntities))
        )
    }
    
    /// Generates migration mapping model between two schemas
    public static func createMappingModel(from source: DataSchema, to destination: DataSchema) -> NSMappingModel? {
        let sourceModel = source.createCoreDataModel()
        let destinationModel = destination.createCoreDataModel()
        
        return try? NSMappingModel.inferredMappingModel(
            forSourceModel: sourceModel,
            destinationModel: destinationModel
        )
    }
}

/// Schema difference information
public struct SchemaDiff {
    public let addedEntities: [String]
    public let removedEntities: [String]
    public let modifiedEntities: [String]
    
    public var hasChanges: Bool {
        return !addedEntities.isEmpty || !removedEntities.isEmpty || !modifiedEntities.isEmpty
    }
}

// MARK: - Schema Documentation Generator

/// Generates documentation for schema definitions
public struct SchemaDocumentationGenerator {
    
    /// Generates markdown documentation for a schema
    public static func generateMarkdown(for schema: DataSchema, title: String = "Domain Schema") -> String {
        let model = schema.createCoreDataModel()
        var markdown = "# \(title)\n\n"
        
        for entity in model.entities.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }) {
            guard let entityName = entity.name else { continue }
            
            markdown += "## \(entityName)\n\n"
            
            let attributes = entity.properties.compactMap { $0 as? NSAttributeDescription }
            let relationships = entity.properties.compactMap { $0 as? NSRelationshipDescription }
            
            if !attributes.isEmpty {
                markdown += "### Attributes\n\n"
                markdown += "| Name | Type | Optional |\n"
                markdown += "|------|------|----------|\n"
                
                for attribute in attributes.sorted(by: { $0.name < $1.name }) {
                    let typeName = attributeTypeName(attribute.attributeType)
                    let optional = attribute.isOptional ? "Yes" : "No"
                    markdown += "| \(attribute.name) | \(typeName) | \(optional) |\n"
                }
                markdown += "\n"
            }
            
            if !relationships.isEmpty {
                markdown += "### Relationships\n\n"
                markdown += "| Name | Destination | Optional | To Many |\n"
                markdown += "|------|-------------|----------|----------|\n"
                
                for relationship in relationships.sorted(by: { $0.name < $1.name }) {
                    let destination = relationship.destinationEntity?.name ?? "Unknown"
                    let optional = relationship.isOptional ? "Yes" : "No"
                    let toMany = relationship.maxCount == 1 ? "No" : "Yes"
                    markdown += "| \(relationship.name) | \(destination) | \(optional) | \(toMany) |\n"
                }
                markdown += "\n"
            }
        }
        
        return markdown
    }
    
    private static func attributeTypeName(_ type: NSAttributeType) -> String {
        switch type {
        case .stringAttributeType: return "String"
        case .booleanAttributeType: return "Boolean"
        case .dateAttributeType: return "Date"
        case .integer16AttributeType: return "Int16"
        case .integer32AttributeType: return "Int32"
        case .integer64AttributeType: return "Int64"
        case .doubleAttributeType: return "Double"
        case .floatAttributeType: return "Float"
        case .binaryDataAttributeType: return "Data"
        case .URIAttributeType: return "URL"
        case .decimalAttributeType: return "Decimal"
        case .transformableAttributeType: return "Transformable"
        case .objectIDAttributeType: return "ObjectID"
        case .undefinedAttributeType: return "Undefined"
        @unknown default: return "Unknown"
        }
    }
}
