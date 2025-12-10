import Foundation
import CoreData
import ScopeGraph

extension Scope {
    /// Domain schema definition using ScopeGraph DSL
    public struct Domain {
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
                
                // Account Entity
                EntitySchema("Account", inherits: "Entity") {
                    Field("email", .text)
                    Field("name", .text)
                    Field("phone", .text, optional: true)
                    Field("points", .number, default: 0)
                    Relationship("image", to: "Attachment")
                }
                
                // Attachment Entity
                EntitySchema("Attachment", inherits: "Entity") {
                    Field("sourceURL", .url, optional: true)
                    ExternalDataField("raw", optional: true)
                    ExternalDataField("native", optional: true)
                    Field("sourceHash", .number, optional: true)
                }
                
                // Inbox Entity
                EntitySchema("InboxMessage", inherits: "Entity") {
                    Field("title", .text)
                    Field("subtitle", .text)
                    Field("wasReaded", .boolean, default: false)
                }
                
                // Product Entity
                EntitySchema("Product", inherits: "Entity") {
                    Field("name", .text)
                    Field("productDescription", .text)
                    Field("pointsCost", .number)
                    Field("isOutOfStock", .boolean, default: false)
                    Field("isFavorite", .boolean, default: false)
                    Relationship("images", to: "Attachment", toMany: true, deleteRule: .cascadeDeleteRule)
                }
                
                // Balance Transaction
                EntitySchema("BalanceTransaction", inherits: "Entity") {
                    Field("typeRaw", .text)
                    Field("amount", .number)
                    Field("transactionDescription", .text)
                }
            }
        }
    }
}
