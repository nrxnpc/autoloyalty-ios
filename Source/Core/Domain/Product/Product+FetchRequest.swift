import CoreData
import Foundation

extension Product {
    static func allProductsFetchRequest() -> NSFetchRequest<Product> {
        let request = NSFetchRequest<Product>(entityName: "Product")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.createdAt, ascending: true)]
        return request
    }
    
    static func obsoleteProducts(excludingIDs externalIDs: Set<String>) -> NSFetchRequest<Product> {
        let request = NSFetchRequest<Product>(entityName: "Product")
        request.predicate = NSPredicate(format: "NOT (sync.externalID IN %@)", externalIDs)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.createdAt, ascending: true)]
        return request
    }
    
    static func availableProductsFetchRequest() -> NSFetchRequest<Product> {
        let request = NSFetchRequest<Product>(entityName: "Product")
        request.predicate = NSPredicate(format: "isOutOfStock == NO")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.pointsCost, ascending: true)]
        return request
    }
    
    public static func allDrafts() -> NSFetchRequest<Product> {
        let request = NSFetchRequest<Product>(entityName: "Product")
        request.predicate = NSPredicate(format: "sync.isDraft == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.createdAt, ascending: false)]
        return request
    }
    
    static func by(id: String) -> NSFetchRequest<Product> {
        let request = NSFetchRequest<Product>(entityName: "Product")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.name, ascending: true)]
        request.fetchLimit = 1
        return request
    }
    
    static func byExternalID(_ externalID: String) -> NSFetchRequest<Product> {
        let request = NSFetchRequest<Product>(entityName: "Product")
        request.predicate = NSPredicate(format: "sync.externalID == %@", externalID)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "sync.externalID", ascending: true)]
        return request
    }
    
    /// Fetch all products that have at least one order (my rewards)
    public static func myRewards() -> NSFetchRequest<Product> {
        let request = NSFetchRequest<Product>(entityName: "Product")
        request.predicate = NSPredicate(format: "orders.@count > 0")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.createdAt, ascending: false)]
        return request
    }
    
    /// Fetch all orders for a specific product
    static func ordersForProduct(_ product: Product) -> NSFetchRequest<Order> {
        let request = NSFetchRequest<Order>(entityName: "Order")
        request.predicate = NSPredicate(format: "product == %@", product)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Order.createdAt, ascending: false)]
        return request
    }
}
