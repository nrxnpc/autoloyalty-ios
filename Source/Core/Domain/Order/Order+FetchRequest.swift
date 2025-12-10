import Foundation
import CoreData

extension Order {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }
    
    public static func allOrders() -> NSFetchRequest<Order> {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Order.createdAt, ascending: false)]
        return request
    }
    
    public static func ordersByStatus(_ status: OrderStatus) -> NSFetchRequest<Order> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "statusRaw == %@", status.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Order.createdAt, ascending: false)]
        return request
    }
    
    public static func byID(_ id: String) -> NSFetchRequest<Order> {
        let request = NSFetchRequest<Order>(entityName: "Order")
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return request
    }
    
    public static func byExternalID(_ externalID: String) -> NSFetchRequest<Order> {
        let request = NSFetchRequest<Order>(entityName: "Order")
        request.predicate = NSPredicate(format: "sync.externalID == %@", externalID)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "sync.externalID", ascending: true)]
        return request
    }
}
