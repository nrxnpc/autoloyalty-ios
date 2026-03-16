import Foundation
import CoreData

/// Product domain entity with CoreData support
@objc(Product)
public class Product: Entity {
    @NSManaged public var name: String
    @NSManaged public var productDescription: String
    @NSManaged public var pointsCost: Int
    @NSManaged public var isOutOfStock: Bool
    @NSManaged public var isFavorite: Bool
    @NSManaged public var image: URL?
    
    @NSManaged public var category: String
    @NSManaged public var stockQuantity: Int
    @NSManaged public var isActive: Bool
    
    /// One-to-many relationship: One Product can have multiple Orders
    @NSManaged public var orders: Set<Order>
}

extension Product {
    static func createOrUpdate(from raw: RestEndpoint.Product, in context: NSManagedObjectContext) {
        let request = Product.byExternalID(raw.id)
        if let existing = try? context.fetch(request).first {
            existing.name = raw.name
            existing.productDescription = raw.description
            existing.category = raw.category
            existing.pointsCost = raw.pointsCost
            existing.stockQuantity = raw.stockQuantity
            existing.isActive = raw.isActive
            existing.isOutOfStock = raw.stockQuantity <= 0
            existing.image = URL(string: raw.imageURL)
            if let date = ISO8601DateFormatter().date(from: raw.createdAt) {
                existing.createdAt = date
            }
        } else {
            create(from: raw, in: context)
        }
    }
    
    static func createOrUpdate(from raw: RestEndpoint.OrderProduct, in context: NSManagedObjectContext) -> Product {
        let request = Product.byExternalID(raw.id)
        if let existing = try? context.fetch(request).first {
            existing.name = raw.name
            existing.category = raw.category
            return existing
        } else {
            return create(from: raw, in: context)
        }
    }
    
    private static func create(from raw: RestEndpoint.Product, in context: NSManagedObjectContext) {
        let product = Product(context: context)
        product.sync.externalID = raw.id
        product.name = raw.name
        product.productDescription = raw.description
        product.category = raw.category
        product.pointsCost = raw.pointsCost
        product.stockQuantity = raw.stockQuantity
        product.isActive = raw.isActive
        product.image = URL(string: raw.imageURL)
        product.isOutOfStock = raw.stockQuantity <= 0
        product.isFavorite = false
        product.createdAt = ISO8601DateFormatter().date(from: raw.createdAt) ?? .now
        product.orders = []
    }
    
    private static func create(from raw: RestEndpoint.OrderProduct, in context: NSManagedObjectContext) -> Product {
        let product = Product(context: context)
        product.sync.externalID = raw.id
        product.name = raw.name
        product.productDescription = ""
        product.category = raw.category
        product.pointsCost = 0
        product.stockQuantity = 0
        product.isActive = false
        product.image = nil
        product.isOutOfStock = true
        product.isFavorite = false
        product.createdAt = .now
        product.orders = []
        return product
    }
}

// MARK: - Order Relationship Helpers

extension Product {
    /// Add an order to this product
    public func addToOrders(_ order: Order) {
        var currentOrders = orders
        currentOrders.insert(order)
        orders = currentOrders
    }
    
    /// Remove an order from this product
    public func removeFromOrders(_ order: Order) {
        var currentOrders = orders
        currentOrders.remove(order)
        orders = currentOrders
    }
    
    /// Get all orders sorted by creation date
    public var sortedOrders: [Order] {
        orders.sorted { $0.createdAt > $1.createdAt }
    }
}
