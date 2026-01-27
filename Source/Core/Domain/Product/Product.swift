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
    @NSManaged public var images: Set<Attachment>
    
    @NSManaged public var category: String
    @NSManaged public var stockQuantity: Int
    @NSManaged public var isActive: Bool
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
            if let imageURL = URL(string: raw.imageURL) {
                existing.images = [.fromURL(imageURL, in: context)]
            }
            if let date = ISO8601DateFormatter().date(from: raw.createdAt) {
                existing.createdAt = date
            }
        } else {
            create(from: raw, in: context)
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
        if let imageURL = URL(string: raw.imageURL) {
            product.images = [.fromURL(imageURL, in: context)]
        }
        product.isOutOfStock = raw.stockQuantity <= 0
        product.isFavorite = false
        product.createdAt = ISO8601DateFormatter().date(from: raw.createdAt) ?? .now
    }
}
