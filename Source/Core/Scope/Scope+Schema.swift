import Foundation
import CoreData
import ScopeGraph

extension Scope {
    /// Domain schema definition using ScopeGraph DSL
    public struct CoreData {
        /// Complete domain model schema
        public static var schema: DataSchema {
            DataSchema {
                // Base Entity
                EntitySchema("Entity") {
                    Field("id", .identifier)
                    Field("createdAt", .timestamp)
                    Field("updatedAt", .timestamp)
                    Field("deletedAt", .timestamp, optional: true)
                    Relationship("sync", to: "EntitySync", inverse: "entityReference")
                }
                
                // Entity synchronization record
                EntitySchema("EntitySync") {
                    Field("id", .identifier)
                    Field("isDraft", .boolean, default: false)
                    Field("externalID", .text, optional: true)
                    Field("updatedAt", .timestamp)
                    Relationship("entityReference", to: "Entity", inverse: "sync")
                }
            }
        }
    }
}
