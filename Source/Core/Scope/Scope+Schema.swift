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
                    Relationship("sync", to: "EntitySync", inverse: "entityReference", deleteRule: .cascadeDeleteRule)
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
                    Field("type", .number, default: 0)
                }
                
                // Support Message
                EntitySchema("SupportMessage", inherits: "Entity") {
                    Field("text", .text)
                    Field("isOwned", .boolean, default: false)
                }
                
                // Product Entity
                EntitySchema("Product", inherits: "Entity") {
                    Field("name", .text)
                    Field("productDescription", .text)
                    Field("pointsCost", .number)
                    Field("isOutOfStock", .boolean, default: false)
                    Field("isFavorite", .boolean, default: false)
                    Field("category", .text, default: "")
                    Field("stockQuantity", .number, default: 0)
                    Field("isActive", .boolean, default: true)
                    Field("image", .url, optional: true)
                    Relationship("orders", to: "Order", inverse: "product", toMany: true, deleteRule: .denyDeleteRule)
                }
                
                // Balance Transaction
                EntitySchema("BalanceTransaction", inherits: "Entity") {
                    Field("typeRaw", .text)
                    Field("amount", .number)
                    Field("transactionDescription", .text)
                }
                
                // Order Entity
                EntitySchema("Order", inherits: "Entity") {
                    Field("statusRaw", .text)
                    Field("quantity", .number)
                    Field("totalPoints", .number)
                    Field("productName", .text)
                    Field("productCategory", .text)
                    Field("promocode", .text, optional: true)
                    Field("digitalCertificate", .url, optional: true)
                    Field("instructions", .text, optional: true)
                    Relationship("product", to: "Product", inverse: "orders")
                }
                
                // Scan Item Entity
                EntitySchema("ScanItem", inherits: "Entity") {
                    Field("productName", .text)
                    Field("productCategory", .text)
                    Field("pointsEarned", .number)
                }
                
                // Cars
                
                EntitySchema("CarRecommendation", inherits: "Entity") {
                    Field("brand", .text)
                    Field("model", .text)
                    Field("year", .number)
                    Field("price", .text)
                    Field("imageURL", .url, optional: true)
                    Field("carDescription", .text)
                    Field("isActive", .boolean)
                    
                    // MARK: - User Feedbask
                    
                    Field("sentimentScore", .number, default: 0)
                    
                    // MARK: - Specification
                    
                    Field("engine", .text)
                    Field("transmission", .text)
                    Field("fuelType", .text)
                    Field("bodyType", .text)
                    Field("drivetrain", .text)
                    Field("color", .text)
                }
                
                // Sweepstakes Entity
                EntitySchema("Sweepstakes", inherits: "Entity") {
                    Field("title", .text)
                    Field("promoDescription", .text)
                    Field("startDate", .timestamp)
                    Field("endDate", .timestamp)
                    Field("statusRaw", .int16)
                    Field("entryConditionRaw", .int16)
                    Field("requiredValue", .number, default: 0)
                    Field("image", .url, optional: true)
                    Relationship("prizes", to: "Product", optional: true, toMany: true)
                    Relationship("entries", to: "SweepstakesEntry", inverse: "sweepstakes", toMany: true, deleteRule: .cascadeDeleteRule)
                }
                
                // Sweepstakes Entry Entity
                EntitySchema("SweepstakesEntry", inherits: "Entity") {
                    Field("entryDate", .timestamp)
                    Field("isWinner", .boolean, default: false)
                    Relationship("account", to: "Account")
                    Relationship("sweepstakes", to: "Sweepstakes", inverse: "entries")
                    Relationship("wonProduct", to: "Product", optional: true)
                }
            }
        }
    }
}
