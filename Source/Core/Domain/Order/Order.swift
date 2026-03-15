import Foundation
import CoreData

/// Order domain entity with CoreData support
@objc(Order)
public class Order: Entity {
    @NSManaged public var statusRaw: String
    @NSManaged public var quantity: Int
    @NSManaged public var totalPoints: Int
    @NSManaged public var productName: String
    @NSManaged public var productCategory: String
    
    /// Many-to-one relationship: Each Order must have exactly one Product
    @NSManaged public var product: Product
    
    public enum OrderStatus: String, CaseIterable {
        case pending
        case processing
        case shipped
        case delivered
        case cancelled
    }
    
    public var status: OrderStatus {
        get { OrderStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }
}

extension Order {
    static func createOrUpdate(from raw: RestEndpoint.Order, in context: NSManagedObjectContext) {
        let request = Order.byExternalID(raw.id)
        if let existing = try? context.fetch(request).first {
            existing.status = orderStatus(from: raw.status)
            existing.quantity = raw.quantity
            existing.totalPoints = raw.total_points
            existing.productName = raw.product?.name ?? ""
            existing.productCategory = raw.product?.category ?? ""
            
            // Link to Product if available
            if let productID = raw.product?.id {
                let productRequest = Product.byExternalID(productID)
                if let product = try? context.fetch(productRequest).first {
                    existing.product = product
                } else {
                    // TODO:
                    // Product.createOrUpdate(from: raw.product, in: context)
                }
            }
            
            if let date = ISO8601DateFormatter().date(from: raw.created_at ?? "") {
                existing.createdAt = date
            }
        } else {
            create(from: raw, in: context)
        }
    }
    
    private static func create(from raw: RestEndpoint.Order, in context: NSManagedObjectContext) {
        // Ensure Product exists before creating Order
        guard let productID = raw.product?.id,
              let productRequest = try? context.fetch(Product.byExternalID(productID)),
              let product = productRequest.first else {
            return // Cannot create Order without Product
        }
        
        let order = Order(context: context)
        order.sync.externalID = raw.id
        order.status = orderStatus(from: raw.status)
        order.quantity = raw.quantity
        order.totalPoints = raw.total_points
        order.productName = raw.product?.name ?? ""
        order.productCategory = raw.product?.category ?? ""
        order.product = product
        order.createdAt = ISO8601DateFormatter().date(from: raw.created_at ?? "") ?? .now
    }
    
    private static func orderStatus(from status: RestEndpoint.OrderStatus) -> OrderStatus {
        switch status {
        case .pending: return .pending
        case .processing: return .processing
        case .shipped: return .shipped
        case .delivered: return .delivered
        case .cancelled: return .cancelled
        }
    }
}
