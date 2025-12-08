import CoreData
import Foundation

extension Product {
    static func allProductsFetchRequest() -> NSFetchRequest<Product> {
        let request = NSFetchRequest<Product>(entityName: "Product")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.name, ascending: true)]
        return request
    }
    
    static func availableProductsFetchRequest() -> NSFetchRequest<Product> {
        let request = NSFetchRequest<Product>(entityName: "Product")
        request.predicate = NSPredicate(format: "isOutOfStock == NO")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.pointsCost, ascending: true)]
        return request
    }
    
    static func by(id: String) -> NSFetchRequest<Product> {
        let request = NSFetchRequest<Product>(entityName: "Product")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.name, ascending: true)]
        request.fetchLimit = 1
        return request
    }
}
